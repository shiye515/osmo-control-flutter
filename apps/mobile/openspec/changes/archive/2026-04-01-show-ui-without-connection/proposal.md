## Why

当前没有设备连接时，主界面完全空白，用户体验不佳。应该显示界面框架，用占位符（横线）替代数据，让用户知道界面布局和预期功能。

## What Changes

- 移除 `StatusTilesGrid` 中 `isConnected` 为 false 时返回空 Widget 的逻辑
- 未连接时显示所有磁贴，数据用 "--" 占位符替代
- 未连接时禁用交互功能（如录制控制、模式切换）
- 连接磁贴显示"未连接"状态，点击可弹出扫描弹窗

## Capabilities

### New Capabilities

无新增能力

### Modified Capabilities

- `camera-status-tiles`: 修改磁贴显示逻辑，支持未连接状态显示占位符

## Impact

- `lib/ui/status_tiles_grid.dart` - 修改 `build` 方法，支持未连接状态
- `lib/ui/status_tile.dart` - 可能需要添加禁用/占位符样式