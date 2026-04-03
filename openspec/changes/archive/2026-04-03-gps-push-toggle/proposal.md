## Why

当前 GPS 自动推送开关位于独立的 GPS 设置页面，用户需要导航到单独页面才能控制。将开关直接集成到首页磁帖中可以简化操作流程，一键开启/关闭 GPS 推送，无需额外导航。

## What Changes

- 将 GPS 自动推送开关集成到首页磁帖网格中，替换现有 GPS 状态显示磁帖
- 磁帖点击行为变为开关切换（点击开启 → 点击关闭）
- **BREAKING** 移除独立 GPS 设置页面及其路由

## Capabilities

### New Capabilities
- `gps-toggle-tile`: 首页磁帖显示 GPS 推送状态，支持点击切换开启/关闭

### Modified Capabilities
- `gps-push`: 修改需求，移除独立的 GPS 设置页面入口，推送控制通过首页磁帖完成

## Impact

- `status_tiles_grid.dart`: `_GpsTile` 组件改为可点击的开关磁帖
- `gps_settings_view.dart`: 删除整个文件
- `routes.dart`: 移除 GPS 路由
- `GpsProvider`: 需暴露 `autoPushEnabled` 状态和切换方法给磁帖
- 本地化字符串：可能需要调整相关文案