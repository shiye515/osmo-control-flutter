import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/// Service for handling device GPS location.
class LocationService {
  static final _log = Logger('LocationService');

  StreamSubscription<Position>? _positionSubscription;
  final _positionController = StreamController<Position>.broadcast();

  /// Stream of position updates.
  Stream<Position> get positionStream => _positionController.stream;

  /// Current position.
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission.
  /// Returns true if permission granted.
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Ensure location permission is granted.
  /// Returns true if permission is available.
  Future<bool> ensurePermission() async {
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

    return true;
  }

  /// Get current position once.
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
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
  Future<void> startPositionStream({int distanceFilter = 0}) async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return;

    await stopPositionStream();

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        _log.warning('Position stream error: $error');
      },
    );

    _log.info('Started position stream');
  }

  /// Stop position updates.
  Future<void> stopPositionStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
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
