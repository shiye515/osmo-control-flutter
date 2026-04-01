## Why

当前 GPS 页面仅显示基本的经纬度、高度和精度信息。用户需要更详细的 GPS 数据用于专业场景（如测绘、运动分析等），包括速度分量、精度估计和卫星状态。

## What Changes

- 扩展 `GpsPointModel` 模型，添加速度分量和精度字段
- 修改 `LocationService` 获取完整的 GPS 位置信息
- 更新 `GpsProvider` 传递新的 GPS 数据
- 重新设计 GPS 页面上方的信息面板，展示完整的 GPS 状态

### 新增数据字段

| 字段 | 说明 |
|------|------|
| 经度 (longitude) | 已有 |
| 纬度 (latitude) | 已有 |
| 高度 (altitude) | 已有 |
| 向北速度 (speedNorth) | 南北方向速度分量 |
| 向东速度 (speedEast) | 东西方向速度分量 |
| 垂直速度 (speedVertical) | 上升/下降速度 |
| 水平精度 (horizontalAccuracy) | 已有 (accuracy) |
| 垂直精度 (verticalAccuracy) | 高度精度 |
| 速度精度 (speedAccuracy) | 速度测量精度 |
| 卫星数量 (satelliteCount) | 用于定位的卫星数 |

## Capabilities

### New Capabilities

- `gps-info-panel`: GPS 信息面板组件，展示完整的位置和速度信息

### Modified Capabilities

- `gps-push`: 扩展 GPS 数据模型，包含更多位置属性

## Impact

- `lib/models/gps_point_model.dart` - 添加新字段
- `lib/services/location_service.dart` - 提取完整 GPS 数据
- `lib/providers/gps_provider.dart` - 传递新数据
- `lib/view/gps/gps_settings_view.dart` - 重新设计信息面板
- `lib/l10n/app_*.arb` - 添加新的本地化字符串