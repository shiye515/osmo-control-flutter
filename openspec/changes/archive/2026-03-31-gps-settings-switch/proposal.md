## Why

用户需要一个开关来控制是否从手机获取 GPS 数据。当前 GPS 设置页面只有"自动推送"开关，但没有控制 GPS 数据获取本身的开关。如果用户不需要 GPS 功能，应用仍然会持续请求位置权限和获取 GPS 数据。同时，工作台需要显示 GPS 数据磁贴，让用户能直观看到当前位置状态。

## What Changes

- 在 GPS 设置页面增加"启用 GPS"开关，控制是否获取手机 GPS 数据
- 当开关开启时，调用 LocationService 获取 GPS 位置
- 当开关关闭时，停止 GPS 位置获取
- 在工作台 StatusTilesGrid 中增加 GPS 数据磁贴，显示当前经纬度
- GPS 磁贴仅在 GPS 开关开启且有位置数据时显示有效数据

## Capabilities

### New Capabilities

- `gps-toggle`: GPS 获取开关控制功能，控制是否从手机获取 GPS 位置数据

### Modified Capabilities

- `camera-status-tiles`: 增加 GPS 数据磁贴显示当前经纬度信息
- `gps-push`: 增加 GPS 启用状态控制，只有启用后才会获取 GPS 数据用于推送

## Impact

- `lib/view/gps/gps_settings_view.dart`: 增加 GPS 启用开关
- `lib/providers/gps_provider.dart`: 增加 GPS 启用状态管理，集成 LocationService
- `lib/ui/status_tiles_grid.dart`: 增加 GPS 数据磁贴
- `lib/services/location_service.dart`: 已有，用于获取 GPS 数据