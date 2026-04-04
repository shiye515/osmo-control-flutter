import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/gps_point_model.dart';
import '../services/background_service.dart';
import '../services/location_service.dart';
import 'session_provider.dart';

class GpsProvider extends ChangeNotifier {
  static final _log = Logger('GpsProvider');

  SessionProvider? _sessionProvider;
  LocationService? _locationService;
  BackgroundServiceManager? _backgroundService;

  GpsPointModel? _lastGpsPoint;
  bool _autoPushEnabled = false;

  bool _gpsEnabled = false;
  StreamSubscription? _locationSubscription;

  // Throttle control
  DateTime? _lastPushTime;
  static const _minPushIntervalMs = 500; // 0.5秒 (2Hz max)

  // Failure tracking
  int _consecutivePushFailures = 0;
  static const _maxConsecutiveFailures = 3;

  // Permission denied callback
  Function? _onPermissionDenied;

  static const _kGpsEnabledKey = 'gps_enabled';

  GpsPointModel? get lastGpsPoint => _lastGpsPoint;
  bool get autoPushEnabled => _autoPushEnabled;
  bool get gpsEnabled => _gpsEnabled;

  void updateSession(SessionProvider session) {
    _sessionProvider = session;
  }

  void setLocationService(LocationService service) {
    _locationService = service;
  }

  void setBackgroundService(BackgroundServiceManager service) {
    _backgroundService = service;
  }

  void setOnPermissionDenied(Function callback) {
    _onPermissionDenied = callback;
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
        // Notify permission denied
        _onPermissionDenied?.call();
        return false;
      }

      // Start background service on Android when GPS is enabled
      if (Platform.isAndroid && _backgroundService != null) {
        await _backgroundService!.start();
      }
    } else {
      _stopLocationStream();
      _lastGpsPoint = null;

      // Stop background service on Android when GPS is disabled
      if (Platform.isAndroid && _backgroundService != null) {
        await _backgroundService!.stop();
      }
    }
    notifyListeners();
    return true;
  }

  Future<bool> _startLocationStream() async {
    if (_locationService == null) return false;

    // Request background permission (always permission) for background mode
    final hasPermission = await _locationService!.ensurePermission(backgroundMode: true);
    if (!hasPermission) {
      _log.warning('Background location permission not granted');
      return false;
    }

    // Start position stream with background mode enabled
    final success = await _locationService!.startPositionStream(backgroundMode: true);
    if (!success) {
      return false;
    }

    _locationSubscription = _locationService!.positionStream.listen((position) {
      _lastGpsPoint = GpsPointModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        verticalAccuracy: position.altitudeAccuracy,
        speedAccuracy: position.speedAccuracy,
        timestamp: position.timestamp,
      );
      notifyListeners();

      // Real-time push with throttle: push GPS data when auto-push is enabled and throttle allows
      if (_autoPushEnabled && _shouldPush()) {
        _sessionProvider?.pushGps(_lastGpsPoint!).then((success) {
          if (success) {
            _consecutivePushFailures = 0;
          } else {
            _consecutivePushFailures++;
            if (_consecutivePushFailures >= _maxConsecutiveFailures) {
              _log.warning('GPS push consecutive failures: $_consecutivePushFailures');
            }
          }
        });
        _lastPushTime = DateTime.now();
      }
    });
    return true;
  }

  /// Check if throttle allows a new push.
  bool _shouldPush() {
    if (_lastPushTime == null) return true;
    return DateTime.now().difference(_lastPushTime!).inMilliseconds >= _minPushIntervalMs;
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

  Future<void> setAutoPushEnabled(bool enabled) async {
    _autoPushEnabled = enabled;
    if (enabled) {
      // Auto-start GPS when enabling auto-push
      if (!_gpsEnabled) {
        await setGpsEnabled(true);
      }
      // Push current location immediately if available (bypass throttle for first push)
      if (_lastGpsPoint != null && _shouldPush()) {
        _lastPushTime = DateTime.now();
        _sessionProvider?.pushGps(_lastGpsPoint!);
      }
    }
    notifyListeners();
  }

  Future<void> pushGpsNow(double lat, double lng, double alt) async {
    final point = GpsPointModel(
      latitude: lat,
      longitude: lng,
      altitude: alt,
      accuracy: 0,
      speed: 0,
      heading: 0,
      timestamp: DateTime.now(),
    );
    _lastGpsPoint = point;
    notifyListeners();
    await _sessionProvider?.pushGps(point);
  }

  @override
  void dispose() {
    _stopLocationStream();
    super.dispose();
  }
}