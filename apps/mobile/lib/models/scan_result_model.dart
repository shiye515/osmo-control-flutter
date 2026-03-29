class ScanResultModel {
  final String deviceId;
  final String deviceName;
  final int rssi;
  final DateTime discoveredAt;

  const ScanResultModel({
    required this.deviceId,
    required this.deviceName,
    required this.rssi,
    required this.discoveredAt,
  });

  @override
  bool operator ==(Object other) =>
      other is ScanResultModel && other.deviceId == deviceId;

  @override
  int get hashCode => deviceId.hashCode;
}
