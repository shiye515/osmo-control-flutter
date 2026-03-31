import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/gps_point_model.dart';
import '../services/location_service.dart';
import 'session_provider.dart';

class GpsProvider extends ChangeNotifier {
  SessionProvider? _sessionProvider;
  LocationService? _locationService;

  GpsPointModel? _lastGpsPoint;
  bool _autoPushEnabled = false;
  double _frequencyHz = 1.0;
  Timer? _autoPushTimer;

  bool _gpsEnabled = false;
  StreamSubscription? _locationSubscription;

  static const _kGpsEnabledKey = 'gps_enabled';

  GpsPointModel? get lastGpsPoint => _lastGpsPoint;
  bool get autoPushEnabled => _autoPushEnabled;
  double get frequencyHz => _frequencyHz;
  bool get gpsEnabled => _gpsEnabled;

  void updateSession(SessionProvider session) {
    _sessionProvider = session;
  }

  void setLocationService(LocationService service) {
    _locationService = service;
  }

  Future<void> loadGpsEnabledState() async {
    final prefs = await SharedPreferences.getInstance();
    _gpsEnabled = prefs.getBool(_kGpsEnabledKey) ?? false;
    if (_gpsEnabled) {
      await _startLocationStream();
    }
    notifyListeners();
  }

  Future<bool> setGpsEnabled(bool enabled) async {
    if (_gpsEnabled == enabled) return true;
    _gpsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kGpsEnabledKey, enabled);

    if (enabled) {
      final success = await _startLocationStream();
      if (!success) {
        _gpsEnabled = false;
        await prefs.setBool(_kGpsEnabledKey, false);
        notifyListeners();
        return false;
      }
    } else {
      _stopLocationStream();
      _lastGpsPoint = null;
    }
    notifyListeners();
    return true;
  }

  Future<bool> _startLocationStream() async {
    if (_locationService == null) return false;

    final hasPermission = await _locationService!.ensurePermission();
    if (!hasPermission) {
      return false;
    }

    await _locationService!.startPositionStream();
    _locationSubscription = _locationService!.positionStream.listen((position) {
      _lastGpsPoint = GpsPointModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
      notifyListeners();
    });
    return true;
  }

  void _stopLocationStream() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationService?.stopPositionStream();
  }

  void setLastGpsPoint(GpsPointModel point) {
    _lastGpsPoint = point;
    notifyListeners();
  }

  void setAutoPushEnabled(bool enabled) {
    _autoPushEnabled = enabled;
    if (enabled) {
      _startAutoPush();
    } else {
      _stopAutoPush();
    }
    notifyListeners();
  }

  void setFrequencyHz(double hz) {
    _frequencyHz = hz;
    if (_autoPushEnabled) {
      _stopAutoPush();
      _startAutoPush();
    }
    notifyListeners();
  }

  void _startAutoPush() {
    _stopAutoPush();
    // Clamp interval between 100 ms (10 Hz) and 60 000 ms (1/60 Hz).
    final intervalMs = (_frequencyHz > 0 ? (1000 / _frequencyHz) : 1000)
        .round()
        .clamp(100, 60000);
    _autoPushTimer = Timer.periodic(
        Duration(milliseconds: intervalMs), (_) => _pushCurrentLocation());
  }

  void _stopAutoPush() {
    _autoPushTimer?.cancel();
    _autoPushTimer = null;
  }

  Future<void> _pushCurrentLocation() async {
    final point = _lastGpsPoint;
    if (point == null) return;
    await _sessionProvider?.pushGps(
        point.latitude, point.longitude, point.altitude);
  }

  Future<void> pushGpsNow(double lat, double lng, double alt) async {
    final point = GpsPointModel(
      latitude: lat,
      longitude: lng,
      altitude: alt,
      accuracy: 0,
      timestamp: DateTime.now(),
    );
    _lastGpsPoint = point;
    notifyListeners();
    await _sessionProvider?.pushGps(lat, lng, alt);
  }

  @override
  void dispose() {
    _stopAutoPush();
    _stopLocationStream();
    super.dispose();
  }
}
