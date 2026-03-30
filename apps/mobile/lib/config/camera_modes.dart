import 'package:flutter/material.dart';

/// Camera mode definition with mode value, display name and icon.
typedef CameraModeDef = ({int mode, String name, IconData icon});

/// Supported camera modes.
const List<CameraModeDef> kCameraModes = [
  (mode: 0x00, name: '慢动作', icon: Icons.slow_motion_video),
  (mode: 0x01, name: '视频', icon: Icons.videocam),
  (mode: 0x02, name: '静止延时', icon: Icons.timelapse),
  (mode: 0x05, name: '拍照', icon: Icons.camera_alt),
  (mode: 0x0A, name: '运动延时', icon: Icons.motion_photos_on),
  (mode: 0x28, name: '低光视频', icon: Icons.nights_stay),
  (mode: 0x34, name: '人物跟随', icon: Icons.person_pin),
];

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