## Why

当前底部导航栏仅包含3个入口（遥控器、调试台、设置），占用屏幕空间且功能分散。将设置入口集成到首页磁帖网格中，可以简化界面布局，同时将调试台入口移至设置页面内部，使主界面更加聚焦于核心控制功能。

## What Changes

- **BREAKING** 移除底部导航栏（BottomNavigationBar）
- 在首页磁帖网格第一行第4个位置添加设置入口磁帖
- 将调试台入口从底部导航移动到设置页面
- 设置页面使用 `AboutListTile` 组件展示应用关于信息
- 首页改为单页面结构，不再需要 ShellRoute 导航

## Capabilities

### New Capabilities
- `settings-tile`: 首页磁帖网格中的设置入口磁帖

### Modified Capabilities
- `device-scan-dialog`: 移除底部导航后，页面结构简化为单页面模式

## Impact

- `home_shell.dart`: 移除 BottomNavigationBar，改为直接显示 WorkbenchView
- `status_tiles_grid.dart`: 添加设置磁帖（第一行第4个位置）
- `settings_view.dart`: 添加调试台入口链接、使用 AboutListTile 展示关于信息
- `app_router.dart`: 简化路由结构，移除 ShellRoute 或调整为单一页面
- 本地化：可能需要新增"关于"相关字符串