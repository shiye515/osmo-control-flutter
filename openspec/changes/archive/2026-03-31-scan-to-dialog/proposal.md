## Why

当前设备扫描页面是独立页面，用户每次切换设备需要跳转页面，操作不够便捷。将扫描功能改为弹窗形式，点击连接状态磁贴即可弹出，提供更流畅的用户体验。

## What Changes

- 将 `DeviceScanView` 从独立页面改为弹窗组件 `DeviceScanDialog`
- 修改应用启动逻辑：未连接设备时直接显示工作台，并自动弹出扫描弹窗
- 点击连接状态磁贴时弹出扫描弹窗，可切换连接其他设备
- 移除 `/scan` 路由，应用直接启动到工作台
- 断开连接后弹出扫描弹窗，而不是跳转页面

## Capabilities

### New Capabilities

- `device-scan-dialog`: 设备扫描弹窗组件，替代独立页面

### Modified Capabilities

- `camera-status-tiles`: 连接状态磁贴点击行为从断开连接改为弹出扫描弹窗

## Impact

- `lib/routes/app_router.dart`: 移除 `/scan` 路由
- `lib/view/scan/device_scan_view.dart`: 重构为 `DeviceScanDialog` 弹窗组件
- `lib/ui/status_tiles_grid.dart`: 连接状态磁贴点击行为修改
- `lib/view/workbench/workbench_view.dart`: 未连接时自动弹出扫描弹窗
- `lib/main.dart`: 启动逻辑调整