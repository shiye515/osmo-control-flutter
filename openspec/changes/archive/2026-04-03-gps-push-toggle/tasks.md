## 1. 修改首页 GPS 磁帖

- [x] 1.1 将 `_GpsTile` 改为可点击的开关磁帖，点击切换 `autoPushEnabled`
- [x] 1.2 磁帖样式：开启时显示绿色图标，关闭时显示灰色图标
- [x] 1.3 添加 `onGpsToggle` 回调参数给 `StatusTilesGrid`

## 2. 移除 GPS 设置页面

- [x] 2.1 删除 `gps_settings_view.dart` 文件
- [x] 2.2 从路由中移除 `/gps` 路由入口
- [x] 2.3 从底部导航栏移除 GPS 入口（如有）
- [x] 2.4 清理相关的导入和引用

## 3. 测试验证

- [x] 3.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 3.2 手动测试：点击磁帖开启 GPS 推送，再次点击关闭