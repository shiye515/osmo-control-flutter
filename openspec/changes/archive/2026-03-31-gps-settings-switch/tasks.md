## 1. GpsProvider 改造

- [x] 1.1 在 GpsProvider 中添加 LocationService 实例
- [x] 1.2 在 GpsProvider 中添加 gpsEnabled 状态字段
- [x] 1.3 实现 setGpsEnabled 方法，控制 LocationService 启停
- [x] 1.4 添加 GPS 状态持久化逻辑（使用 SharedPreferences）

## 2. GPS 设置页面 UI

- [x] 2.1 在 gps_settings_view.dart 顶部添加"启用 GPS"开关
- [x] 2.2 开关下方显示当前 GPS 状态（启用/禁用）
- [x] 2.3 实现开关状态变化时调用 GpsProvider.setGpsEnabled
- [x] 2.4 处理权限请求失败情况，显示提示

## 3. GPS 数据磁贴

- [x] 3.1 在 StatusTilesGrid 中添加 GPS 数据磁贴组件
- [x] 3.2 磁贴根据 gpsEnabled 状态显示不同内容（启用/禁用/获取中）
- [x] 3.3 磁贴显示当前经纬度数值
- [x] 3.4 位置数据更新时磁贴内容实时更新

## 4. Provider 集成

- [x] 4.1 在 main.dart 中初始化 LocationService 并注入 GpsProvider
- [x] 4.2 确保应用启动时恢复 GPS 启用状态
- [x] 4.3 测试 GPS 开关开启/关闭流程