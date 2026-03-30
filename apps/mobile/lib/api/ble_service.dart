import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';

import '../config/app_constants.dart';
import '../models/scan_result_model.dart';

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

  StreamController<List<int>>? _notifyController;
  Stream<List<int>>? get notifyStream => _notifyController?.stream;

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

  Future<bool> connect(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      _connectedDevice = device;

      await device.connect(
        timeout: const Duration(seconds: 10),
        license: License.free,
      );

      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.toString().toUpperCase() ==
            AppConstants.osmoServiceUuid) {
          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toUpperCase();
            if (uuid == AppConstants.osmoWriteCharUuid) {
              _writeCharacteristic = char;
            } else if (uuid == AppConstants.osmoNotifyCharUuid) {
              await char.setNotifyValue(true);
              _notifyController = StreamController<List<int>>.broadcast();
              char.lastValueStream.listen(_notifyController!.add);
            }
          }
        }
      }

      _connectionStateController.add(true);
      _log.info('Connected to $deviceId');
      return true;
    } catch (e) {
      _log.warning('Connect failed: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyController?.close();
    _notifyController = null;
    _connectionStateController.add(false);
  }

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

  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _scanResultsController.close();
    _connectionStateController.close();
    _notifyController?.close();
  }
}
