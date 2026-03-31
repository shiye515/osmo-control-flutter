## 1. 依赖配置

- [x] 1.1 添加 geolocator 依赖到 pubspec.yaml
- [x] 1.2 运行 flutter pub get

## 2. Android 权限配置

- [x] 2.1 在 AndroidManifest.xml 添加 ACCESS_FINE_LOCATION 权限
- [x] 2.2 在 AndroidManifest.xml 添加 ACCESS_COARSE_LOCATION 权限
- [x] 2.3 确保 compileSdkVersion 设置为 35

## 3. iOS 权限配置

- [x] 3.1 在 Info.plist 添加 NSLocationWhenInUseUsageDescription
- [x] 3.2 配置 Podfile 禁用后台定位权限

## 4. 服务实现

- [x] 4.1 创建 LocationService 类
- [x] 4.2 实现权限检查和请求方法
- [x] 4.3 实现获取当前位置方法
- [x] 4.4 实现位置流订阅

## 5. 集成测试

- [x] 5.1 测试 Android 权限请求流程
- [x] 5.2 测试 iOS 权限请求流程
- [x] 5.3 测试位置获取功能