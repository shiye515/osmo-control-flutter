import 'package:flutter/material.dart';

/// Device type enumeration based on device_id from camera connection response.
enum DeviceType {
  osmoAction4,    // device_id = 0xFF33
  osmoAction5Pro, // device_id = 0xFF44
  osmoAction6,    // device_id = 0xFF55
  osmo360,        // device_id = 0xFF66
  unknown,        // unrecognized device
}

/// Device ID constants for DJI cameras.
const int kOsmoAction4DeviceId = 0xFF33;
const int kOsmoAction5ProDeviceId = 0xFF44;
const int kOsmoAction6DeviceId = 0xFF55;
const int kOsmo360DeviceId = 0xFF66;

/// Get device type from device_id.
DeviceType getDeviceType(int deviceId) {
  switch (deviceId) {
    case kOsmoAction4DeviceId:
      return DeviceType.osmoAction4;
    case kOsmoAction5ProDeviceId:
      return DeviceType.osmoAction5Pro;
    case kOsmoAction6DeviceId:
      return DeviceType.osmoAction6;
    case kOsmo360DeviceId:
      return DeviceType.osmo360;
    default:
      return DeviceType.unknown;
  }
}

/// Camera mode definition with mode value, display name and icon.
typedef CameraModeDef = ({int mode, String name, IconData icon});

/// Supported camera modes (all devices).
const List<CameraModeDef> kCameraModes = [
  (mode: 0x00, name: '慢动作', icon: Icons.slow_motion_video),
  (mode: 0x01, name: '视频', icon: Icons.videocam),
  (mode: 0x02, name: '静止延时', icon: Icons.timelapse),
  (mode: 0x05, name: '拍照', icon: Icons.camera_alt),
  (mode: 0x0A, name: '运动延时', icon: Icons.motion_photos_on),
  (mode: 0x28, name: '低光视频', icon: Icons.nights_stay),
  (mode: 0x34, name: '人物跟随', icon: Icons.person_pin),
];

/// Osmo Action 4 supported modes only (4 modes).
const List<CameraModeDef> kOsmoAction4Modes = [
  (mode: 0x00, name: '慢动作', icon: Icons.slow_motion_video),
  (mode: 0x01, name: '视频', icon: Icons.videocam),
  (mode: 0x02, name: '静止延时', icon: Icons.timelapse),
  (mode: 0x05, name: '拍照', icon: Icons.camera_alt),
];

/// Get supported camera modes based on device type.
/// Osmo Action 4 only supports 4 modes; other devices support all modes.
List<CameraModeDef> getSupportedModes(int deviceId) {
  final deviceType = getDeviceType(deviceId);
  if (deviceType == DeviceType.osmoAction4) {
    return kOsmoAction4Modes;
  }
  return kCameraModes;
}

/// Get mode definition by mode value.
CameraModeDef? getCameraModeDef(int mode) {
  for (final def in kCameraModes) {
    if (def.mode == mode) return def;
  }
  return null;
}

/// Get mode index in list, returns 0 if not found.
int getCameraModeIndex(int mode) {
  for (int i = 0; i < kCameraModes.length; i++) {
    if (kCameraModes[i].mode == mode) return i;
  }
  return 0; // Default to first mode
}