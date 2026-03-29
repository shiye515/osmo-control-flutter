import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../api/ble_service.dart';
import '../models/scan_result_model.dart';

class BleProvider extends ChangeNotifier {
  final BleService _bleService = BleService();

  List<ScanResultModel> _scanResults = [];
  bool _isScanning = false;
  bool _isAvailable = false;

  StreamSubscription<List<ScanResultModel>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;

  List<ScanResultModel> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  bool get isAvailable => _isAvailable;

  BleProvider() {
    _initBle();
  }

  void _initBle() {
    _adapterSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _isAvailable = state == BluetoothAdapterState.on;
      notifyListeners();
    });

    _scanSubscription = _bleService.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    if (!_isAvailable) return;
    _isScanning = true;
    _scanResults = [];
    notifyListeners();
    await _bleService.startScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> stopScan() async {
    await _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connect(String deviceId) async {
    return _bleService.connect(deviceId);
  }

  Future<void> disconnect() async {
    await _bleService.disconnect();
  }

  Future<bool> write(List<int> data) async {
    return _bleService.write(data);
  }

  Stream<List<int>>? get notifyStream => _bleService.notifyStream;

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _bleService.dispose();
    super.dispose();
  }
}
