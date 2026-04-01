import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../config/app_constants.dart';
import '../models/scan_result_model.dart';
import '../models/camera_status_model.dart';
import 'dji_r_protocol.dart';

class BleService {
  static final _log = Logger('BleService');

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;

  final _scanResultsController =
      StreamController<List<ScanResultModel>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Stream<List<ScanResultModel>> get scanResults =>
      _scanResultsController.stream;
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  final Map<String, ScanResultModel> _discovered = {};
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamController<List<int>>? _notifyController;
  Stream<List<int>>? get notifyStream => _notifyController?.stream;

  StreamSubscription<List<int>>? _notifySubscription;
  final _frameBuffer = <int>[];

  // Auth state
  Completer<bool>? _authCompleter;
  int _cameraDeviceId = 0;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  Future<void> startScan() async {
    _discovered.clear();
    _isScanning = true;

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: AppConstants.scanTimeoutSeconds),
      withKeywords: [AppConstants.osmoDeviceNamePrefix],
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.platformName;
        if (name.startsWith(AppConstants.osmoDeviceNamePrefix)) {
          _discovered[r.device.remoteId.str] = ScanResultModel(
            deviceId: r.device.remoteId.str,
            deviceName: name,
            rssi: r.rssi,
            discoveredAt: DateTime.now(),
          );
        }
      }
      _scanResultsController.add(List.unmodifiable(_discovered.values));
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning = scanning;
      if (!scanning) {
        _scanSubscription?.cancel();
      }
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _isScanning = false;
  }

  Future<bool> connect(String deviceId, {bool useDjiRAuth = true}) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;

      await device.connect(
        timeout: const Duration(seconds: 10),
        license: License.free,
      );

      final services = await device.discoverServices();
      for (final service in services) {
        final serviceUuid = service.uuid.toString().toUpperCase();
        final isOsmoService = serviceUuid.contains('FFF0') ||
            serviceUuid == AppConstants.osmoServiceUuid;

        if (isOsmoService) {
          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toUpperCase();
            final shortUuid = uuid.replaceAll('-', '').substring(0, 4);
            final isWrite = shortUuid == 'FFF5';
            final isNotify = shortUuid == 'FFF4';

            if (isWrite) {
              _writeCharacteristic = char;
            } else if (isNotify) {
              _notifyCharacteristic = char;
              await char.setNotifyValue(true);
              _notifyController = StreamController<List<int>>.broadcast();
              _notifySubscription = char.lastValueStream.listen(_onDataReceived);
              char.lastValueStream.listen(_notifyController!.add);
            }
          }
        }
      }

      if (_writeCharacteristic == null) {
        _log.warning('Write characteristic not found');
        await disconnect();
        return false;
      }

      if (useDjiRAuth) {
        return await _performDjiRAuth();
      } else {
        _connectionStateController.add(true);
        _log.info('Connected to $deviceId');
        return true;
      }
    } catch (e) {
      _log.warning('Connect failed: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Perform DJI R SDK authentication flow.
  Future<bool> _performDjiRAuth() async {
    _authCompleter = Completer<bool>();
    _frameBuffer.clear();

    const controllerDeviceId = 0x00000001;
    final controllerMac = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66];

    final frame = DjiRProtocol.buildConnectionRequest(
      deviceId: controllerDeviceId,
      macAddr: controllerMac,
      verifyMode: 0,
      verifyData: 0,
    );

    _log.info('Sending connection request...');
    final writeSuccess = await _writeFrame(frame);
    if (!writeSuccess) {
      _log.warning('Failed to write connection request');
      _connectionStateController.add(false);
      return false;
    }

    return await _authCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _log.warning('Auth timeout');
        _connectionStateController.add(false);
        return false;
      },
    );
  }

  /// Handle received data.
  void _onDataReceived(List<int> data) {
    _frameBuffer.addAll(data);
    _parseFrames();
  }

  /// Parse frames from buffer (supports both DUML 0x55 and DJI R SDK 0xAA).
  void _parseFrames() {
    while (_frameBuffer.isNotEmpty) {
      final sof = _frameBuffer[0];

      if (sof != 0xAA && sof != 0x55) {
        _frameBuffer.removeAt(0);
        continue;
      }

      if (_frameBuffer.length < 3) break;

      if (sof == 0xAA) {
        final frameLen = _frameBuffer[1] | ((_frameBuffer[2] & 0x03) << 8);
        if (_frameBuffer.length < frameLen) break;

        final frameData = _frameBuffer.sublist(0, frameLen);
        _frameBuffer.removeRange(0, frameLen);

        final frame = DjiRProtocol.parse(frameData);
        if (frame != null) {
          _handleFrame(frame);
        }
      } else if (sof == 0x55) {
        final frameLen = _frameBuffer[1] | ((_frameBuffer[2] & 0x03) << 8);
        if (_frameBuffer.length < frameLen) break;

        final frameData = _frameBuffer.sublist(0, frameLen);
        _frameBuffer.removeRange(0, frameLen);

        _log.fine('DUML frame: ${frameData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }
    }
  }

  /// Handle parsed DJI R SDK frame.
  void _handleFrame(DjiRFrame frame) {
    _log.info('RX DJI-R: cmdSet=0x${frame.cmdSet.toRadixString(16)}, cmdId=0x${frame.cmdId.toRadixString(16)}, isAck=${frame.isAck}');

    // Connection response (CmdSet=0x00, CmdID=0x19)
    if (frame.cmdSet == 0x00 && frame.cmdId == 0x19) {
      _handleConnectionFrame(frame);
    }

    // Camera status push (CmdSet=0x1D, CmdID=0x02)
    if (frame.cmdSet == 0x1D && frame.cmdId == 0x02) {
      _handleCameraStatusPush(frame);
    }

    // Mode switch response (CmdSet=0x1D, CmdID=0x04)
    if (frame.cmdSet == 0x1D && frame.cmdId == 0x04 && frame.isAck) {
      final ackCode = frame.payload.isNotEmpty ? frame.payload[0] : 0xFF;
      if (ackCode == 0x00) {
        _log.info('Mode switch succeeded');
      } else {
        _log.warning('Mode switch failed: ack=$ackCode');
      }
    }

    // Recording control response (CmdSet=0x1D, CmdID=0x03)
    if (frame.cmdSet == 0x1D && frame.cmdId == 0x03 && frame.isAck) {
      final ackCode = frame.payload.isNotEmpty ? frame.payload[0] : 0xFF;
      if (ackCode == 0x00) {
        _log.info('Recording control succeeded');
      } else {
        _log.warning('Recording control failed: ack=$ackCode');
      }
    }
  }

  /// Handle connection frame.
  void _handleConnectionFrame(DjiRFrame frame) {
    if (frame.isAck) return;

    final payload = DjiRProtocol.parseConnectionPayload(frame.payload);
    if (payload == null) return;

    if (payload.verifyMode == 2) {
      _cameraDeviceId = payload.deviceId;

      if (payload.verifyData == 0) {
        final ackFrame = DjiRProtocol.buildConnectionAck(
          deviceId: _cameraDeviceId,
          cameraIndex: 0,
        );
        _writeFrame(ackFrame).then((_) {
          _log.info('Connected to camera');
          _connectionStateController.add(true);
          _authCompleter?.complete(true);
          // Subscribe to status push after connection
          subscribeCameraStatus();
        });
      } else {
        _log.warning('Camera rejected connection');
        _connectionStateController.add(false);
        _authCompleter?.complete(false);
      }
    }
  }

  /// Handle camera status push.
  void _handleCameraStatusPush(DjiRFrame frame) {
    final payload = frame.payload;

    final newStatus = CameraStatusModel.fromPayload(payload);

    // Log mode changes
    if (_cameraStatus.cameraMode != newStatus.cameraMode) {
      _log.info('Camera mode changed: 0x${_cameraStatus.cameraMode.toRadixString(16)} -> 0x${newStatus.cameraMode.toRadixString(16)}');
    }

    // Update power mode if changed
    if (payload.length > 28) {
      final powerMode = payload[28];
      _updatePowerMode(powerMode);
    }

    // Emit status update
    _cameraStatus = newStatus;
    _cameraStatusController.add(newStatus);
  }

  /// Update power mode state.
  void _updatePowerMode(int newMode) {
    if (_powerMode != newMode) {
      _log.info('Power mode: ${newMode == 3 ? "sleep" : "normal"}');
      _powerMode = newMode;
      _powerModeController.add(newMode);
    }
  }

  /// Write a DJI R SDK frame.
  Future<bool> _writeFrame(List<int> frame) async {
    if (_writeCharacteristic == null) return false;
    try {
      _log.info('TX DJI-R: ${frame.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      await _writeCharacteristic!.write(frame, withoutResponse: false);
      return true;
    } catch (e) {
      _log.warning('Write failed: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _notifyController?.close();
    _notifyController = null;
    _frameBuffer.clear();
    _cameraDeviceId = 0;
    _powerMode = 0;
    _cameraStatus = const CameraStatusModel();
    _connectionStateController.add(false);
  }

  /// Write raw data (for DUML protocol commands).
  Future<bool> write(List<int> data) async {
    if (_writeCharacteristic == null) {
      _log.warning('Write characteristic not found');
      return false;
    }
    try {
      _log.info('TX DUML: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      await _writeCharacteristic!.write(data, withoutResponse: false);
      return true;
    } catch (e) {
      _log.warning('Write failed: $e');
      return false;
    }
  }

  /// Get connected camera device ID.
  int get cameraDeviceId => _cameraDeviceId;

  // Power mode state
  int _powerMode = 0; // 0=normal, 3=sleep
  final _powerModeController = StreamController<int>.broadcast();

  // Camera status state
  CameraStatusModel _cameraStatus = const CameraStatusModel();
  final _cameraStatusController = StreamController<CameraStatusModel>.broadcast();

  /// Current power mode (0=normal, 3=sleep).
  int get powerMode => _powerMode;

  /// Stream of power mode changes.
  Stream<int> get powerModeStream => _powerModeController.stream;

  /// Current camera status.
  CameraStatusModel get cameraStatus => _cameraStatus;

  /// Stream of camera status changes.
  Stream<CameraStatusModel> get cameraStatusStream => _cameraStatusController.stream;

  /// Send sleep command to camera.
  Future<bool> sendSleepCommand() async {
    if (_writeCharacteristic == null) return false;

    _log.info('Sending sleep command');
    final frame = DjiRProtocol.buildSleepCommand();
    return await _writeFrame(frame);
  }

  /// Send wake command to camera.
  Future<bool> sendWakeCommand() async {
    if (_writeCharacteristic == null) return false;

    _log.info('Sending wake command');
    final frame = DjiRProtocol.buildWakeCommand();
    return await _writeFrame(frame);
  }

  /// Request camera status push.
  Future<bool> requestCameraStatus() async {
    if (_writeCharacteristic == null) return false;

    _log.info('Requesting camera status');
    final frame = DjiRProtocol.buildRequestStatus();
    return await _writeFrame(frame);
  }

  /// Subscribe to camera status push.
  Future<bool> subscribeCameraStatus() async {
    if (_writeCharacteristic == null) return false;
    final frame = DjiRProtocol.buildStatusSubscription();
    return await _writeFrame(frame);
  }

  /// Send switch mode command.
  Future<bool> sendSwitchModeCommand(int mode) async {
    if (_writeCharacteristic == null) return false;
    _log.info('Sending switch mode via DJI R SDK: 0x${mode.toRadixString(16)}');
    final frame = DjiRProtocol.buildSwitchModeCommand(mode, deviceId: _cameraDeviceId);
    return await _writeFrame(frame);
  }

  /// Send toggle recording command.
  /// isRecording: true = send stop command, false = send start command
  Future<bool> sendToggleRecordingCommand(bool isRecording) async {
    if (_writeCharacteristic == null) return false;
    final action = isRecording ? 'stop' : 'start';
    _log.info('Sending $action recording via DJI R SDK');
    final frame = DjiRProtocol.buildToggleRecordingCommand(
      deviceId: _cameraDeviceId,
      recordCtrl: isRecording ? 1 : 0,  // 0=start, 1=stop
    );
    return await _writeFrame(frame);
  }

  /// Send take snapshot command.
  Future<bool> sendTakeSnapshotCommand() async {
    if (_writeCharacteristic == null) return false;
    _log.info('Sending take snapshot via DJI R SDK');
    final frame = DjiRProtocol.buildTakeSnapshotCommand(deviceId: _cameraDeviceId);
    return await _writeFrame(frame);
  }

  /// Send GPS data push command.
  Future<bool> sendPushGps({
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double altitude,
    required double speedNorth,
    required double speedEast,
    required double speedDownward,
    required int verticalAccuracy,
    required int horizontalAccuracy,
    required int speedAccuracy,
    required int satelliteCount,
  }) async {
    if (_writeCharacteristic == null) return false;
    _log.info('Sending GPS push: lat=$latitude, lng=$longitude, alt=$altitude');
    final frame = DjiRProtocol.buildPushGps(
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      speedNorth: speedNorth,
      speedEast: speedEast,
      speedDownward: speedDownward,
      verticalAccuracy: verticalAccuracy,
      horizontalAccuracy: horizontalAccuracy,
      speedAccuracy: speedAccuracy,
      satelliteCount: satelliteCount,
    );
    return await _writeFrame(frame);
  }

  /// Generate wake-up advertisement data for a sleeping camera.
  static List<int> getWakeUpAdvData(String macAddress) {
    return DjiRProtocol.buildWakeUpAdvData(macAddress);
  }

  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _scanResultsController.close();
    _connectionStateController.close();
    _powerModeController.close();
    _cameraStatusController.close();
    _notifyController?.close();
  }
}
