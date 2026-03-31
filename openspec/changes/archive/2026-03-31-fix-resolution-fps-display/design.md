## Context

当前 `CameraStatusModel` 的 `fpsDisplay` getter 直接使用 `fpsIdx` 作为帧率数值显示：
```dart
String get fpsDisplay => '${fpsIdx}fps';
```

根据 DJI R SDK 协议文档，`video_resolution` 和 `fps_idx` 有明确的映射表，不是简单的索引值。

## Goals / Non-Goals

**Goals:**
- 根据官方协议文档正确映射 video_resolution 和 fps_idx
- 显示用户可理解的分辨率和帧率信息

**Non-Goals:**
- 不添加帧率切换功能

## Decisions

### 决策 1：video_resolution 映射表

根据 DJI R SDK 协议文档：

| video_resolution | 显示名称 |
|------------------|----------|
| 10 | 1080P |
| 16 | 4K |
| 45 | 2.7K |
| 66 | 1080P 9:16 |
| 67 | 2.7K 9:16 |
| 95 | 2.7K 4:3 |
| 103 | 4K 4:3 |
| 109 | 4K 9:16 |
| 4 (拍照) | L |
| 3 (拍照) | M |

### 决策 2：fps_idx 映射表

| fps_idx | 帧率 |
|---------|------|
| 1 | 24fps |
| 2 | 25fps |
| 3 | 30fps |
| 4 | 48fps |
| 5 | 50fps |
| 6 | 60fps |
| 7 | 120fps |
| 8 | 240fps |
| 10 | 100fps |
| 19 | 200fps |

注：慢动作模式下，fps_idx 表示倍率 = 帧率 / 30

## Risks / Trade-offs

**风险：新分辨率值可能未在映射表中**
- 如果设备返回未知的值，显示原始数值方便调试