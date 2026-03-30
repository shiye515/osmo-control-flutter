import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../config/app_constants.dart';
import '../models/scan_result_model.dart';
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
      _log.info('=== Starting BLE connection to $deviceId ===');

      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;

      _log.info('Step 1: Connecting to device...');
      await device.connect(
        timeout: const Duration(seconds: 10),
        license: License.free,
      );
      _log.info('Step 2: BLE connected, discovering services...');

      final services = await device.discoverServices();
      _log.info('Found ${services.length} services');

      for (final service in services) {
        final serviceUuid = service.uuid.toString().toUpperCase();
        _log.info('Service: $serviceUuid');
        _log.info('Expected service: ${AppConstants.osmoServiceUuid}');

        // Check if this is Osmo service (compare short form)
        final isOsmoService = serviceUuid.contains('FFF0') ||
            serviceUuid == AppConstants.osmoServiceUuid;
        _log.info('Is Osmo service: $isOsmoService');

        if (isOsmoService) {
          _log.info('Found Osmo service! Characteristic count: ${service.characteristics.length}');
          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toUpperCase();
            _log.info('Characteristic UUID: $uuid');
            _log.info('Expected write: ${AppConstants.osmoWriteCharUuid}');
            _log.info('Expected notify: ${AppConstants.osmoNotifyCharUuid}');

            // Check short form match (FFF5, FFF4)
            final shortUuid = uuid.replaceAll('-', '').substring(0, 4);
            final isWrite = shortUuid == 'FFF5';
            final isNotify = shortUuid == 'FFF4';
            _log.info('shortUuid=$shortUuid, isWrite=$isWrite, isNotify=$isNotify');

            if (isWrite) {
              _writeCharacteristic = char;
              _log.info('!!! Write characteristic FOUND: $uuid');
            } else if (isNotify) {
              _notifyCharacteristic = char;
              await char.setNotifyValue(true);
              _notifyController = StreamController<List<int>>.broadcast();
              _notifySubscription = char.lastValueStream.listen(_onDataReceived);
              char.lastValueStream.listen(_notifyController!.add);
              _log.info('!!! Notify characteristic FOUND and subscribed: $uuid');
            }
          }
        }
      }

      if (_writeCharacteristic == null) {
        _log.warning('!!! Write characteristic NOT found');
        await disconnect();
        return false;
      }

      _log.info('Step 3: Characteristics ready, auth mode: $useDjiRAuth');

      if (useDjiRAuth) {
        // DJI R SDK authentication flow
        return await _performDjiRAuth();
      } else {
        // Legacy mode - no auth
        _connectionStateController.add(true);
        _log.info('=== Connected (no auth mode) ===');
        return true;
      }
    } catch (e) {
      _log.warning('!!! Connect failed: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Perform DJI R SDK authentication flow.
  Future<bool> _performDjiRAuth() async {
    _log.info('=== Starting DJI R SDK auth ===');
    _authCompleter = Completer<bool>();
    _frameBuffer.clear();

    // Controller device ID (placeholder)
    const controllerDeviceId = 0x00000001;

    // Controller MAC (placeholder - should get from device)
    final controllerMac = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66];

    // Build and send connection request (verify_mode=0 for already paired)
    _log.info('Building connection request frame...');
    final frame = DjiRProtocol.buildConnectionRequest(
      deviceId: controllerDeviceId,
      macAddr: controllerMac,
      verifyMode: 0,
      verifyData: 0,
    );

    _log.info('Frame length: ${frame.length} bytes');
    _log.info('Frame hex: ${frame.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    _log.info('Sending connection request...');
    final writeSuccess = await _writeFrame(frame);
    if (!writeSuccess) {
      _log.warning('!!! Failed to write frame');
      _connectionStateController.add(false);
      return false;
    }

    _log.info('Waiting for camera response (timeout 10s)...');

    // Wait for auth result
    return await _authCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _log.warning('!!! Auth timeout - no response from camera');
        _log.warning('Buffer content: ${_frameBuffer.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
        _connectionStateController.add(false);
        return false;
      },
    );
  }

  /// Handle received data.
  void _onDataReceived(List<int> data) {
    // Print raw data for debugging
    _log.info('Raw data received: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    _frameBuffer.addAll(data);
    _parseFrames();
  }

  /// Parse frames from buffer (supports both DUML 0x55 and DJI R SDK 0xAA).
  void _parseFrames() {
    _log.info('Parsing frames, buffer size: ${_frameBuffer.length}');

    while (_frameBuffer.isNotEmpty) {
      final sof = _frameBuffer[0];

      // Skip unknown bytes
      if (sof != 0xAA && sof != 0x55) {
        _log.warning('Unknown SOF: 0x${sof.toRadixString(16)}, removing from buffer');
        _frameBuffer.removeAt(0);
        continue;
      }

      if (_frameBuffer.length < 3) {
        _log.info('Buffer too short for frame header (< 3 bytes)');
        break;
      }

      // Try to parse based on SOF type
      if (sof == 0xAA) {
        // DJI R SDK protocol
        final frameLen = _frameBuffer[1] | ((_frameBuffer[2] & 0x03) << 8);
        _log.info('DJI R SDK frame, expected length: $frameLen, buffer size: ${_frameBuffer.length}');

        if (_frameBuffer.length < frameLen) {
          _log.info('Incomplete DJI R SDK frame, waiting for more data');
          break;
        }

        final frameData = _frameBuffer.sublist(0, frameLen);
        _frameBuffer.removeRange(0, frameLen);

        _log.info('Parsing DJI R SDK frame (len=$frameLen): ${frameData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

        final frame = DjiRProtocol.parse(frameData);
        if (frame != null) {
          _log.info('!!! Successfully parsed DJI R SDK frame: cmdSet=${frame.cmdSet}, cmdId=${frame.cmdId}, isAck=${frame.isAck}');
          _handleFrame(frame);
        } else {
          _log.warning('!!! Failed to parse DJI R SDK frame (CRC mismatch?)');
        }
      } else if (sof == 0x55) {
        // DUML protocol
        final frameLen = _frameBuffer[1] | ((_frameBuffer[2] & 0x03) << 8);
        _log.info('DUML frame, expected length: $frameLen, buffer size: ${_frameBuffer.length}');

        if (_frameBuffer.length < frameLen) {
          _log.info('Incomplete DUML frame, waiting for more data');
          break;
        }

        final frameData = _frameBuffer.sublist(0, frameLen);
        _frameBuffer.removeRange(0, frameLen);

        _log.info('Received DUML frame (len=$frameLen): ${frameData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

        // For DUML, we don't handle connection flow - it's already connected
        if (frameData.length >= 12) {
          final cmdSet = frameData[10];
          final cmdId = frameData[11];
          _log.info('DUML cmdSet=$cmdSet cmdId=$cmdId');
        }
      }
    }
  }

  /// Handle parsed DJI R SDK frame.
  void _handleFrame(DjiRFrame frame) {
    _log.fine('Received DJI R frame: $frame');

    // Connection response (CmdSet=0x00, CmdID=0x19)
    if (frame.cmdSet == 0x00 && frame.cmdId == 0x19) {
      _handleConnectionFrame(frame);
    }
  }

  /// Handle connection frame.
  void _handleConnectionFrame(DjiRFrame frame) {
    _log.info('=== Handling connection frame ===');
    _log.info('isAck=${frame.isAck}, payloadLen=${frame.payload.length}');
    _log.info('Payload hex: ${frame.payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    if (frame.isAck) {
      // Camera acknowledged our request
      _log.info('Camera acknowledged connection request (ACK received)');
      return;
    }

    // Camera sending verify result (verify_mode=2)
    final payload = DjiRProtocol.parseConnectionPayload(frame.payload);
    if (payload == null) {
      _log.warning('!!! Failed to parse connection payload');
      return;
    }

    _log.info('Parsed payload: deviceId=${payload.deviceId}, verifyMode=${payload.verifyMode}, verifyData=${payload.verifyData}');

    if (payload.verifyMode == 2) {
      _cameraDeviceId = payload.deviceId;

      if (payload.verifyData == 0) {
        // Connection allowed
        _log.info('!!! Camera ALLOWED connection (device_id=$_cameraDeviceId)');
        final ackFrame = DjiRProtocol.buildConnectionAck(
          deviceId: _cameraDeviceId,
          cameraIndex: 0,
        );
        _writeFrame(ackFrame).then((_) {
          _log.info('=== Connection complete ===');
          _connectionStateController.add(true);
          _authCompleter?.complete(true);
        });
      } else {
        // Connection rejected
        _log.warning('!!! Camera REJECTED connection (verifyData=${payload.verifyData})');
        _connectionStateController.add(false);
        _authCompleter?.complete(false);
      }
    } else {
      _log.info('verifyMode=${payload.verifyMode} (not 2, ignoring)');
    }
  }

  /// Write a DJI R SDK frame.
  Future<bool> _writeFrame(List<int> frame) async {
    if (_writeCharacteristic == null) return false;
    try {
      _log.info('Sending frame: ${frame.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      await _writeCharacteristic!.write(frame, withoutResponse: false);
      return true;
    } catch (e) {
      _log.warning('Write frame failed: $e');
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
    _connectionStateController.add(false);
  }

  /// Write raw data (for DUML protocol commands).
  Future<bool> write(List<int> data) async {
    if (_writeCharacteristic == null) {
      _log.warning('Write characteristic not found');
      return false;
    }
    try {
      await _writeCharacteristic!.write(data, withoutResponse: false);
      return true;
    } catch (e) {
      _log.warning('Write failed: $e');
      return false;
    }
  }

  /// Get connected camera device ID.
  int get cameraDeviceId => _cameraDeviceId;

  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _scanResultsController.close();
    _connectionStateController.close();
    _notifyController?.close();
  }
}
