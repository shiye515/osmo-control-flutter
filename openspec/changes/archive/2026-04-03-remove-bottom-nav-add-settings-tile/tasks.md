## 1. 移除底部导航栏

- [x] 1.1 修改 `home_shell.dart`，移除 BottomNavigationBar
- [x] 1.2 修改 `app_router.dart`，简化路由结构（移除 ShellRoute 或调整为单页面模式）

## 2. 添加设置磁帖

- [x] 2.1 在 `status_tiles_grid.dart` 第一行第4个位置添加设置磁帖
- [x] 2.2 设置磁帖点击后导航到设置页面

## 3. 修改设置页面

- [x] 3.1 在 `settings_view.dart` 添加调试台入口 ListTile
- [x] 3.2 使用 `AboutListTile` 组件替换现有的关于信息展示

## 4. 测试验证

- [x] 4.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 4.2 手动测试：验证设置磁帖导航、调试台入口、AboutListTile 功能