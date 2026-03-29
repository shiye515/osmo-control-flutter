class GpsPointModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final DateTime timestamp;

  const GpsPointModel({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  String toString() =>
      'GPS(lat=$latitude, lng=$longitude, alt=$altitude, acc=$accuracy)';
}
