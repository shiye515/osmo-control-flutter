import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../api/protocol_codec.dart';
import '../config/app_constants.dart';
import '../models/session_device_model.dart';
import '../models/camera_status_model.dart';
import '../models/scan_result_model.dart';
import '../models/debug_log_model.dart';
import 'ble_provider.dart';

class SessionProvider extends ChangeNotifier {
  static final _log = Logger('SessionProvider');

  BleProvider? _bleProvider;

  SessionDeviceModel? _connectedDevice;
  CameraStatusModel _cameraStatus = const CameraStatusModel();
  List<ScanResultModel> _scanResults = [];
  final List<DebugLogEntry> _logs = [];
  bool _isFakeMode = false;
  String? _lastError;

  SessionDeviceModel? get connectedDevice => _connectedDevice;
  CameraStatusModel get cameraStatus => _cameraStatus;
  List<ScanResultModel> get scanResults => _scanResults;
  List<DebugLogEntry> get logs => List.unmodifiable(_logs);
  bool get isFakeMode => _isFakeMode;
  String? get lastError => _lastError;
  bool get isConnected => _connectedDevice?.isConnected ?? false;
  bool get isAuthenticated => _connectedDevice?.isAuthenticated ?? false;
  int get powerMode => _bleProvider?.powerMode ?? 0;
  bool get isSleeping => powerMode == 3;

  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<int>? _powerModeSubscription;
  StreamSubscription<CameraStatusModel>? _cameraStatusSubscription;

  void updateBleProvider(BleProvider ble) {
    _bleProvider = ble;
    _scanResults = ble.scanResults;
    notifyListeners();
  }

  Future<void> startScan() async {
    await _bleProvider?.startScan();
    _scanResults = _bleProvider?.scanResults ?? [];
    notifyListeners();
  }

  Future<void> stopScan() async {
    await _bleProvider?.stopScan();
    notifyListeners();
  }

  Future<bool> connect(String deviceId, String deviceName) async {
    _connectedDevice = SessionDeviceModel(
      deviceId: deviceId,
      deviceName: deviceName,
      connectionState: DeviceConnectionState.connecting,
    );
    notifyListeners();

    final success = await _bleProvider?.connect(deviceId) ?? false;
    if (success) {
      _connectedDevice = _connectedDevice!.copyWith(
        connectionState: DeviceConnectionState.authenticated,
      );
      _addLog(LogDirection.system, 'Connected to $deviceName');
      _subscribeNotifications();
    } else {
      _connectedDevice = null;
      _lastError = 'Connection failed';
      _addLog(LogDirection.system, 'Connection failed to $deviceName');
    }
    notifyListeners();
    return success;
  }

  void _subscribeNotifications() {
    _notifySubscription?.cancel();
    _notifySubscription =
        _bleProvider?.notifyStream?.listen(_handleNotification);

    _powerModeSubscription?.cancel();
    _powerModeSubscription =
        _bleProvider?.powerModeStream.listen((mode) {
          _log.info('Power mode changed: $mode (${mode == 3 ? "sleep" : "normal"})');
          notifyListeners();
        });

    _cameraStatusSubscription?.cancel();
    _cameraStatusSubscription =
        _bleProvider?.cameraStatusStream.listen((status) {
          _cameraStatus = status;
          _log.info('Camera status updated: ${status.cameraStatusDisplay}');
          notifyListeners();
        });
  }

  void _handleNotification(List<int> data) {
    _addLog(LogDirection.received, 'RX: ${_hexStr(data)}', rawBytes: data);
    _parseResponse(data);
    notifyListeners();
  }

  void _parseResponse(List<int> data) {
    final payload = ProtocolCodec.parseResponse(data);
    if (payload == null) return;
    if (data.length < 12) return;

    final cmdSet = data[10];
    final cmdId = data[11];

    // DUML response: first payload byte is ack code (0x00 = success)
    final ackCode = payload.isNotEmpty ? payload[0] : 0xFF;

    if (ackCode != 0x00) {
      _log.warning('Command failed: cmdSet=$cmdSet, cmdId=$cmdId, ack=$ackCode');
      return;
    }

    // Recording toggle response (cmdSet 0x01, cmdId 0x4B)
    if (cmdSet == 0x01 && cmdId == 0x4B) {
      _cameraStatus = _cameraStatus.copyWith(
        isRecording: !_cameraStatus.isRecording,
      );
      _log.info('Recording state changed: ${_cameraStatus.isRecording}');
    }
  }

  Future<bool> sendRawCommand(List<int> bytes) async {
    _addLog(LogDirection.sent, 'TX: ${_hexStr(bytes)}', rawBytes: bytes);
    return await _bleProvider?.write(bytes) ?? false;
  }

  Future<void> toggleRecording() async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _cameraStatus = _cameraStatus.copyWith(
          isRecording: !_cameraStatus.isRecording);
      _addLog(LogDirection.system, '[Fake] Toggle recording');
      notifyListeners();
      return;
    }
    final cmd = ProtocolCodec.buildToggleRecording();
    await sendRawCommand(cmd);
    notifyListeners();
  }

  Future<void> takeSnapshot() async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _addLog(LogDirection.system, '[Fake] Take snapshot');
      return;
    }
    final cmd = ProtocolCodec.buildTakeSnapshot();
    await sendRawCommand(cmd);
  }

  Future<void> switchMode(int mode) async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _cameraStatus = _cameraStatus.copyWith(cameraMode: mode);
      _addLog(LogDirection.system, '[Fake] Switch mode to $mode');
      notifyListeners();
      return;
    }
    final cmd = ProtocolCodec.buildSwitchMode(mode);
    await sendRawCommand(cmd);
  }

  Future<void> sleep() async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _addLog(LogDirection.system, '[Fake] Sleep');
      return;
    }
    _log.info('=== Sending sleep command ===');
    final success = await _bleProvider?.sendSleepCommand() ?? false;
    if (success) {
      _addLog(LogDirection.system, 'Sleep command sent');
    } else {
      _addLog(LogDirection.system, 'Failed to send sleep command');
    }
  }

  Future<void> wake() async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _addLog(LogDirection.system, '[Fake] Wake');
      return;
    }
    _log.info('=== Sending wake command ===');
    final success = await _bleProvider?.sendWakeCommand() ?? false;
    if (success) {
      _addLog(LogDirection.system, 'Wake command sent');
    } else {
      _addLog(LogDirection.system, 'Failed to send wake command');
    }
  }

  Future<void> requestVersion() async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _connectedDevice = _connectedDevice?.copyWith(firmwareVersion: 'Fake v1.0.0');
      _addLog(LogDirection.system, '[Fake] Status subscription');
      notifyListeners();
      return;
    }
    await _bleProvider?.subscribeCameraStatus();
  }

  Future<void> pushGps(
      double latitude, double longitude, double altitude) async {
    if (!isConnected && !_isFakeMode) return;
    if (_isFakeMode) {
      _addLog(LogDirection.system,
          '[Fake] GPS push: $latitude, $longitude, $altitude');
      return;
    }
    final cmd = ProtocolCodec.buildPushGps(
        latitude: latitude, longitude: longitude, altitude: altitude);
    await sendRawCommand(cmd);
  }

  Future<void> disconnect() async {
    await _bleProvider?.disconnect();
    _connectedDevice = null;
    _notifySubscription?.cancel();
    _powerModeSubscription?.cancel();
    _cameraStatusSubscription?.cancel();
    _cameraStatus = const CameraStatusModel();
    _addLog(LogDirection.system, 'Disconnected');
    notifyListeners();
  }

  void enableFakeMode(bool enabled) {
    _isFakeMode = enabled;
    if (enabled) {
      _connectedDevice = const SessionDeviceModel(
        deviceId: 'fake-device-001',
        deviceName: 'Osmo Pocket (Fake)',
        connectionState: DeviceConnectionState.authenticated,
        firmwareVersion: 'Fake v1.0.0',
        batteryLevel: 85,
      );
      _cameraStatus = const CameraStatusModel(
        isRecording: false,
        cameraMode: 1, // Video mode
        cameraStatus: 1, // Idle
        batteryPercent: 85,
        remainCapacityMB: 32768, // 32GB
        videoResolution: 0, // 4K
        fpsIdx: 60,
      );
      _addLog(LogDirection.system, 'Fake device mode enabled');
    } else {
      _connectedDevice = null;
      _cameraStatus = const CameraStatusModel();
      _addLog(LogDirection.system, 'Fake device mode disabled');
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void _addLog(LogDirection direction, String message,
      {List<int>? rawBytes}) {
    _logs.add(DebugLogEntry(
      timestamp: DateTime.now(),
      direction: direction,
      message: message,
      rawBytes: rawBytes,
    ));
    if (_logs.length > AppConstants.maxDebugLogEntries) _logs.removeAt(0);
    _log.info(message);
  }

  String _hexStr(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
}
