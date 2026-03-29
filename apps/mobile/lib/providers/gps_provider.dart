import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/gps_point_model.dart';
import 'session_provider.dart';

class GpsProvider extends ChangeNotifier {
  SessionProvider? _sessionProvider;

  GpsPointModel? _lastGpsPoint;
  bool _autoPushEnabled = false;
  double _frequencyHz = 1.0;
  Timer? _autoPushTimer;

  GpsPointModel? get lastGpsPoint => _lastGpsPoint;
  bool get autoPushEnabled => _autoPushEnabled;
  double get frequencyHz => _frequencyHz;

  void updateSession(SessionProvider session) {
    _sessionProvider = session;
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
    final interval = Duration(
        milliseconds: (_frequencyHz > 0 ? (1000 / _frequencyHz) : 1000)
            .round());
    _autoPushTimer = Timer.periodic(interval, (_) => _pushCurrentLocation());
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
    super.dispose();
  }
}
