## Context

Flutter 提供 `ListWheelScrollView` 组件，可以创建类似 iOS 时间选择器的滚轮效果。相机模式已有定义（0x00-0x34），需要创建直观的滚轮选择器。

## Goals / Non-Goals

**Goals:**
- 创建流畅的滚轮模式选择器
- 滚动停止后自动发送切换指令
- 显示当前选中模式的名称
- 支持惯性滚动和吸附效果

**Non-Goals:**
- 不支持自定义模式
- 不支持模式参数设置

## Decisions

### 1. 组件结构

**决定**: 使用 `ListWheelScrollView` + 固定指示器

**结构**:
```
Stack [
  指示器 (中间高亮框)
  ListWheelScrollView (模式列表)
]
```

### 2. 滚动停止检测

**决定**: 使用 `ScrollNotification` + `Timer`

**流程**:
```
用户滚动 → 取消之前的 Timer → 滚动结束 → 启动 500ms Timer
  → Timer 触发 → 发送切换指令
```

### 3. 模式列表

**决定**: 使用静态模式列表

```dart
const List<({int mode, String name, IconData icon})> kCameraModes = [
  (mode: 0x00, name: '慢动作', icon: Icons.slow_motion_video),
  (mode: 0x01, name: '视频', icon: Icons.videocam),
  (mode: 0x02, name: '静止延时', icon: Icons.timelapse),
  (mode: 0x05, name: '拍照', icon: Icons.camera_alt),
  (mode: 0x0A, name: '运动延时', icon: Icons.motion_photos_on),
  (mode: 0x28, name: '低光视频', icon: Icons.nights_stay),
  (mode: 0x34, name: '人物跟随', icon: Icons.person_pin),
];
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 频繁切换模式 | 500ms 防抖延迟 |
| 未知模式值 | 显示"未知模式"并发送指令 |
| 滚动中发送指令 | 只在停止后发送 |