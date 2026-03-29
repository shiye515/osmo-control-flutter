enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  pairing,
  connected,
  authenticated,
}

class SessionDeviceModel {
  final String deviceId;
  final String deviceName;
  final DeviceConnectionState connectionState;
  final String? firmwareVersion;
  final int? batteryLevel;

  const SessionDeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.connectionState,
    this.firmwareVersion,
    this.batteryLevel,
  });

  bool get isConnected =>
      connectionState == DeviceConnectionState.connected ||
      connectionState == DeviceConnectionState.authenticated;

  bool get isAuthenticated =>
      connectionState == DeviceConnectionState.authenticated;

  SessionDeviceModel copyWith({
    String? deviceId,
    String? deviceName,
    DeviceConnectionState? connectionState,
    String? firmwareVersion,
    int? batteryLevel,
  }) {
    return SessionDeviceModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      connectionState: connectionState ?? this.connectionState,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }
}
