import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/// Service for handling device GPS location with background support.
class LocationService {
  static final _log = Logger('LocationService');

  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<Position>.broadcast();

  bool _backgroundModeEnabled = false;

  /// Stream of position updates.
  Stream<Position> get positionStream => _positionController.stream;

  /// Current position.
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Whether background mode is enabled.
  bool get backgroundModeEnabled => _backgroundModeEnabled;

  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission.
  /// If backgroundMode is true, requests 'always' permission.
  /// Returns true if permission granted.
  Future<bool> requestPermission({bool backgroundMode = false}) async {
    LocationPermission permission;

    if (backgroundMode) {
      // Request always permission for background location
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse) {
        // On iOS, need to request again for always permission
        if (Platform.isIOS) {
          permission = await Geolocator.requestPermission();
        }
      }
    } else {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Ensure location permission is granted.
  /// If backgroundMode is true, requires 'always' permission.
  /// Returns true if permission is available.
  Future<bool> ensurePermission({bool backgroundMode = false}) async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      _log.warning('Location service is disabled');
      return false;
    }

    // Check permission
    var permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _log.warning('Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _log.warning('Location permission denied forever');
      return false;
    }

    // For background mode, need 'always' permission
    if (backgroundMode && permission != LocationPermission.always) {
      if (Platform.isIOS) {
        // On iOS, request again to get 'always' permission
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always) {
          _log.warning('Always location permission required for background mode');
          return false;
        }
      } else {
        // On Android, try to request background permission
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always) {
          _log.warning('Background location permission required');
          return false;
        }
      }
    }

    return true;
  }

  /// Get current position once.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _buildLocationSettings(),
      );
      _currentPosition = position;
      return position;
    } catch (e) {
      _log.warning('Failed to get position: $e');
      return null;
    }
  }

  /// Start continuous position updates.
  /// distanceFilter: minimum distance (meters) before triggering update, 0 for real-time.
  /// backgroundMode: if true, enables background location updates.
  Future<bool> startPositionStream({
    int distanceFilter = 0,
    bool backgroundMode = false,
  }) async {
    final hasPermission = await ensurePermission(backgroundMode: backgroundMode);
    if (!hasPermission) return false;

    await stopPositionStream();
    _backgroundModeEnabled = backgroundMode;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(
        distanceFilter: distanceFilter,
        backgroundMode: backgroundMode,
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        _log.warning('Position stream error: $error');
      },
    );

    _log.info('Started position stream (background: $backgroundMode)');
    return true;
  }

  /// Build location settings with platform-specific configurations.
  LocationSettings _buildLocationSettings({
    int distanceFilter = 0,
    bool backgroundMode = false,
  }) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: backgroundMode
            ? const ForegroundNotificationConfig(
                notificationText: '正在获取位置以推送到设备',
                notificationTitle: 'Osmo 遥控器',
                enableWakeLock: true,
                notificationIcon: AndroidResource(name: 'ic_launcher'),
              )
            : null,
      );
    } else if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: backgroundMode,
      );
    }

    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );
  }

  /// Stop position updates.
  Future<void> stopPositionStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _backgroundModeEnabled = false;
    _log.info('Stopped position stream');
  }

  /// Open app settings.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Dispose resources.
  void dispose() {
    stopPositionStream();
    _positionController.close();
  }
}
