## Why

当前应用需要获取设备 GPS 位置信息并推送给相机。需要集成 geolocator 包来实现跨平台的 GPS 定位功能，并正确配置各平台的权限申请。

## What Changes

- 添加 geolocator 依赖
- 配置 Android 权限（ACCESS_FINE_LOCATION、ACCESS_COARSE_LOCATION）
- 配置 iOS 权限（NSLocationWhenInUseUsageDescription）
- 创建 GPS 服务类封装定位逻辑
- 集成到现有的 GPS 推送功能

## Capabilities

### New Capabilities

- `device-location`: 获取设备 GPS 位置信息

### Modified Capabilities

无

## Impact

- `pubspec.yaml`: 添加 geolocator 依赖
- `android/app/src/main/AndroidManifest.xml`: 添加位置权限
- `ios/Runner/Info.plist`: 添加位置权限描述
- 新增 `services/location_service.dart`: GPS 定位服务