## Context

当前应用使用 `geolocator` 包获取 GPS 位置，通过 `flutter_blue_plus` 实现 BLE 通信。在锁屏后，由于系统后台限制，位置获取和蓝牙通信可能被暂停。

**当前状态**：
- LocationService 使用 `Geolocator.getPositionStream()` 但未配置后台参数
- 权限配置已声明后台权限但实际未请求 `always` 级别权限
- Android 已声明 `FOREGROUND_SERVICE_LOCATION` 但未实现 foreground service
- iOS 已配置 `UIBackgroundModes: location` 但未启用 `allowBackgroundLocationUpdates`

**平台限制**：
- Android：锁屏后 BLE 连接可能不稳定，需要 foreground service 保持活跃
- iOS：后台位置更新需要 `always` 权限和特定配置

## Goals / Non-Goals

**Goals:**
- 实现锁屏状态下持续获取真实 GPS 位置并上报到设备
- 后台模式默认开启，应用启动时自动启用
- 保持蓝牙连接稳定，确保数据能正常发送
- 符合 Android/iOS 平台的后台运行规范
- 提供清晰的用户提示（通知、权限引导）

**Non-Goals:**
- 不提供后台模式开关（默认始终开启）
- 不实现完全的后台服务架构（如定时任务、数据同步）
- 不处理应用被杀死后的恢复（仅处理锁屏场景）
- 不实现轨迹存储/历史记录功能

## Decisions

### 1. 后台位置方案选择

**决策**：使用 `flutter_background_service` 包实现后台服务

**考虑的方案**：
1. **flutter_background_service**：提供完整的 foreground service 支持，可同时保持位置获取和蓝牙连接活跃 ✅ 选择
2. **background_locator_2**：专注位置获取，但不支持蓝牙后台
3. **workmanager**：周期性任务，不适合实时数据上报
4. **纯 geolocator 后台配置**：iOS 可用，但 Android BLE 可能不稳定

**理由**：flutter_background_service 可以同时保持位置服务和蓝牙连接活跃，提供统一的后台管理。

### 2. 权限请求策略

**决策**：应用启动时自动请求 `always` 级别权限

**理由**：
- 后台模式默认开启，需要在启动时就请求完整权限
- iOS 后台位置必须请求 `always` 权限
- 如果用户拒绝，提供引导去系统设置授权

### 3. Android Foreground Service 实现

**决策**：应用启动时自动启动 foreground service，无需用户手动开启

**实现要点**：
- 服务类型：`location`
- 启动时机：应用启动时自动启动
- 通知内容：显示"正在获取位置"和连接状态
- 生命周期：随应用生命周期管理

### 4. iOS 后台位置配置

**决策**：使用 geolocator 的 `allowBackgroundLocationUpdates` 和 `pausesLocationUpdatesAutomatically` 配置

**实现要点**：
- 设置 `allowBackgroundLocationUpdates: true`
- 设置 `pausesLocationUpdatesAutomatically: false` 或处理暂停回调
- 显示后台位置使用指示器（iOS 系统要求）

### 5. 权限管理页面设计

**决策**：在设置页面添加权限管理模块，展示所有必需权限及其状态

**需要展示的权限**：
| 权限 | Android | iOS | 说明 |
|------|---------|-----|------|
| 蓝牙 | BLUETOOTH_SCAN/CONNECT | NSBluetoothAlwaysUsageDescription | 连接 Osmo 设备 |
| 位置（使用时） | ACCESS_FINE_LOCATION | NSLocationWhenInUseUsageDescription | 获取 GPS 位置 |
| 位置（后台） | ACCESS_BACKGROUND_LOCATION | NSLocationAlwaysAndWhenInUseUsageDescription | 锁屏后继续获取位置 |

**实现要点**：
- 列表形式展示每个权限
- 显示权限名称、用途说明、当前授权状态（已授权/未授权/永久拒绝）
- 未授权状态：显示"请求授权"按钮，点击触发权限请求
- 永久拒绝状态：显示"打开设置"按钮，跳转到系统应用设置页
- 使用 `permission_handler` 包统一管理权限状态检查和请求

## Risks / Trade-offs

**电池消耗增加** → 后台持续获取 GPS 会增加耗电，在通知中提示用户

**权限被拒绝** → 提供详细引导，告知用户如何在系统设置中授权

**Android 系统差异** → 在多种 Android 版本上测试，处理不同系统的行为差异

**iOS 后台限制更严格** → 遵循 iOS 规范，确保后台位置指示器显示

**蓝牙后台稳定性** → foreground service 可帮助保持连接，但仍需处理断开重连逻辑

## Open Questions

1. 是否需要支持应用被杀死后的自动恢复？（当前 scope 不包含）
2. 通知内容设计？（显示连接状态和 GPS 状态）