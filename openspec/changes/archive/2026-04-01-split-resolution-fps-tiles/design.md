## Context

当前 `_buildSmallTiles` 方法中，分辨率和帧率合并在一个磁贴：
```dart
// Resolution + FPS
StatusTile(
  icon: Icons.videocam_outlined,
  label: status.resolutionDisplay,
  value: status.fpsDisplay,
),
```

需要拆分为两个独立磁贴，并新增 EIS 增稳模式磁贴。

## Goals / Non-Goals

**Goals:**
- 拆分分辨率和帧率为两个独立磁贴
- 新增 EIS 增稳模式磁贴
- 显示增稳模式名称（关闭/RS/HS/RS+/HB）

**Non-Goals:**
- 不修改 EIS 模式切换功能（仅显示）
- 不修改磁贴整体布局结构

## Decisions

### 决策 1：EIS 模式映射

根据 DJI R SDK 协议文档，EIS 模式映射如下：

| eis_mode | 显示名称 | 说明 |
|----------|---------|------|
| 0 | OFF | 关闭增稳 |
| 1 | RS | RockSteady |
| 2 | HS | HorizonSteady |
| 3 | RS+ | RockSteady+ |
| 4 | HB | HorizonBalancing |

### 决策 2：磁贴图标选择

- 分辨率磁贴：`Icons.high_quality_outlined` 或 `Icons.videocam_outlined`
- 帧率磁贴：`Icons.speed_outlined` 或 `Icons.timer_outlined`
- EIS 磁贴：`Icons.stabilization` 或 `Icons.vibration`

## Risks / Trade-offs

**风险：磁贴数量增加**
- 当前 4 列网格布局已接近满载
- 拆分后增加 2 个磁贴，可能需要滚动或调整布局