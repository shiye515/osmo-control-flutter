## Why

用户反馈应用在手机锁屏后停止向设备上报 GPS 数据。经过排查，问题根源是：

1. **GPS 定位在后台被暂停**：当前使用 `geolocator.getPositionStream()` 获取位置，虽然 Android/iOS 都声明了后台位置权限，但没有正确配置后台位置更新模式，导致锁屏后位置流被系统暂停。

2. **蓝牙连接可能中断**：Android 系统在锁屏后可能限制 BLE 活动，没有 foreground service 保持连接活跃，导致蓝牙通信不稳定。

3. **权限级别不足**：当前只请求了 `whileInUse` 级别权限，需要请求 `always` 级别权限才能在后台持续获取位置。

这是核心功能需求，用户需要能够在手机放口袋或锁屏状态下持续记录轨迹。

## What Changes

- 添加 **后台位置服务** 支持，配置 geolocator 的后台位置更新参数
- 添加 **Foreground Service**（Android）保持应用在后台活跃
- 应用启动时自动请求 **Always 级别位置权限** 以支持后台位置获取
- 添加 **通知提示** 显示后台运行状态（Android 要求 foreground service 必须显示通知）
- iOS 配置后台位置更新模式 `allowBackgroundLocationUpdates`
- **后台模式默认开启**，无需用户手动切换
- **设置页面添加权限管理**：列出所有需要的权限、显示授权状态、提供手动授权按钮

## Capabilities

### New Capabilities
- `background-location`: 后台位置获取能力，支持锁屏状态下持续获取 GPS 位置
- `foreground-service`: Android Foreground Service 能力，保持应用在后台运行
- `permission-management`: 设置页面的权限管理功能，展示权限状态并提供授权入口

### Modified Capabilities
- `location-service`: 需要修改位置服务以支持后台模式配置和 Always 权限请求
- `settings-view`: 需要添加权限管理 UI 组件

## Impact

- **新增依赖**：需要添加 `flutter_background_service` 或类似包实现 Android foreground service
- **权限变化**：需要请求 `LocationPermission.always` 权限（用户需要手动在设置中授权）
- **用户体验**：Android 上会显示常驻通知提示"正在获取位置"，后台模式默认开启
- **权限请求**：应用启动时自动请求 always 权限，如被拒绝则引导用户去设置
- **代码影响**：
  - `lib/services/location_service.dart`：添加后台位置配置
  - `lib/providers/gps_provider.dart`：启动时自动启用后台模式
  - `lib/main.dart`：初始化 foreground service