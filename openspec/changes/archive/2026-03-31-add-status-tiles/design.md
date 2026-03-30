## Context

相机状态推送 (CmdSet=0x1D, CmdID=0x02) 包含 20+ 个字段，覆盖了相机的各种状态信息。当前代码已实现连接鉴权，但只解析了 power_mode 字段。需要扩展解析逻辑并创建 UI 组件展示这些信息。

## Goals / Non-Goals

**Goals:**
- 解析所有相机状态推送字段
- 创建正方形磁贴组件（4 个/行）
- 在页面顶部展示 8-12 个常用状态
- 实时更新状态

**Non-Goals:**
- 显示所有 20+ 个字段（只选常用的）
- 编辑相机设置功能

## Decisions

### 1. 磁贴布局

**决定**: 使用 GridView 实现，每行 4 个正方形磁贴

**布局结构**:
```
[电池 85%] [存储 32GB] [剩余 2h30m] [模式 视频]
[4K 60fps] [录制 00:05:23] [温度 正常] [状态 录制中]
```

### 2. 状态模型

**决定**: 扩展现有 CameraStatusModel，添加所有字段

**字段映射**:
```dart
class CameraStatusModel {
  final int batteryPercent;      // camera_bat_percentage
  final int remainCapacityMB;    // remain_capacity
  final int remainPhotoNum;      // remain_photo_num
  final int remainTimeSec;       // remain_time
  final int cameraMode;          // camera_mode
  final int cameraStatus;        // camera_status
  final int videoResolution;     // video_resolution
  final int fpsIdx;              // fps_idx
  final int recordTimeSec;       // record_time
  final int powerMode;           // power_mode
  final int tempOver;            // temp_over
}
```

### 3. 解析时机

**决定**: 在 BleService._handleCameraStatusPush 中解析完整 payload，通过 Stream 发送更新

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 状态更新频繁影响性能 | 使用 throttle 限制更新频率 |
| 磁贴太多占用屏幕空间 | 只显示 8-12 个常用状态 |