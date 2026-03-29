class CameraStatusModel {
  final bool isRecording;
  final int currentMode;
  final double gimbalPitch;
  final double gimbalRoll;
  final double gimbalYaw;
  final int? batteryPercent;
  final String? firmwareVersion;

  const CameraStatusModel({
    this.isRecording = false,
    this.currentMode = 0,
    this.gimbalPitch = 0.0,
    this.gimbalRoll = 0.0,
    this.gimbalYaw = 0.0,
    this.batteryPercent,
    this.firmwareVersion,
  });

  CameraStatusModel copyWith({
    bool? isRecording,
    int? currentMode,
    double? gimbalPitch,
    double? gimbalRoll,
    double? gimbalYaw,
    int? batteryPercent,
    String? firmwareVersion,
  }) {
    return CameraStatusModel(
      isRecording: isRecording ?? this.isRecording,
      currentMode: currentMode ?? this.currentMode,
      gimbalPitch: gimbalPitch ?? this.gimbalPitch,
      gimbalRoll: gimbalRoll ?? this.gimbalRoll,
      gimbalYaw: gimbalYaw ?? this.gimbalYaw,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}
