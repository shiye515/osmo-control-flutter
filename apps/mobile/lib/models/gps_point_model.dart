import 'dart:math';

class GpsPointModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy; // horizontal accuracy in meters
  final double speed; // speed magnitude in m/s (-1 if unavailable)
  final double heading; // direction in degrees (0-360)
  final double? verticalAccuracy; // vertical accuracy in meters
  final double? speedAccuracy; // speed accuracy in m/s
  final DateTime timestamp;

  const GpsPointModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    this.verticalAccuracy,
    this.speedAccuracy,
    required this.timestamp,
  });

  /// Returns true if speed data is available
  bool get hasSpeed => speed >= 0 && !speed.isNaN;

  /// Returns heading, defaulting to 0 if NaN
  double get _safeHeading => heading.isNaN ? 0.0 : heading;

  /// Northward speed component in m/s (positive = north)
  double get speedNorth => hasSpeed ? speed * cos(_safeHeading * pi / 180) : 0;

  /// Eastward speed component in m/s (positive = east)
  double get speedEast => hasSpeed ? speed * sin(_safeHeading * pi / 180) : 0;

  @override
  String toString() =>
      'GPS(lat=$latitude, lng=$longitude, alt=$altitude, speed=$speed, heading=$heading)';
}