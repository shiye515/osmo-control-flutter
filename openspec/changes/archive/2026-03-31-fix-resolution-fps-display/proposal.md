## Why

视频分辨率和帧率数据展示不正确。当前代码将 `fps_idx` 协议字段直接作为帧率数值显示，但实际上 `fps_idx` 是一个索引值，需要映射到实际的帧率。用户看到 "0fps" 或其他不正确的帧率显示，影响使用体验。

## What Changes

- 修复 `fps_idx` 到实际帧率的映射逻辑
- 根据设备类型和分辨率提供正确的帧率范围
- 更新 `CameraStatusModel` 的 `fpsDisplay` getter 以正确映射帧率

## Capabilities

### New Capabilities

无新增能力

### Modified Capabilities

- `camera-status-subscription`: 修改帧率显示逻辑，添加 fps_idx 映射表

## Impact

- `lib/models/camera_status_model.dart` - fpsDisplay getter
- `lib/config/camera_modes.dart` - 可能需要添加 fps 映射表