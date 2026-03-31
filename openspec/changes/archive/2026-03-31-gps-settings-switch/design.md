## Context

当前 GPS 功能已集成到应用中，但用户无法控制是否启用 GPS 数据获取。GPS 设置页面（`gps_settings_view.dart`）显示当前位置信息和自动推送设置，但没有独立的"启用 GPS"开关。

现有的 `LocationService` 已实现 GPS 数据获取功能，`GpsProvider` 管理 GPS 数据状态和自动推送逻辑。工作台 `StatusTilesGrid` 显示相机状态，但未包含 GPS 数据磁贴。

## Goals / Non-Goals

**Goals:**
- 在 GPS 设置页面增加"启用 GPS"开关，控制 GPS 数据获取
- 开关开启时，通过 LocationService 获取位置数据并更新 GpsProvider
- 开关关闭时，停止位置获取并清除位置数据
- 在工作台增加 GPS 数据磁贴，显示当前经纬度

**Non-Goals:**
- 不修改 GPS 推送协议或数据格式
- 不修改 GPS 推送频率逻辑
- 不增加 GPS 后台获取功能

## Decisions

### 1. GPS 开关与自动推送开关分离
**决定**: 两个独立开关控制不同功能
- "启用 GPS"开关：控制是否从手机获取 GPS 数据
- "自动推送"开关：控制是否将 GPS 数据推送到设备（原有功能）

**理由**: 用户可能只想查看 GPS 数据但不推送到设备，或者在不同场景下切换 GPS 功能。

### 2. GPS 开关状态存储在 GpsProvider
**决定**: 在 GpsProvider 中添加 `gpsEnabled` 状态字段

**理由**: 与现有的 `autoPushEnabled` 状态管理模式一致，便于在 Provider 链中传递状态。

### 3. GPS 磁贴位置
**决定**: GPS 磁贴放在 StatusTilesGrid 的小磁贴区域

**理由**: 与其他状态磁贴（电池、存储等）风格一致，不占用主要控制区域。

## Risks / Trade-offs

**[权限请求时机]**: 用户开启 GPS 时需要请求位置权限，可能被拒绝
→ Mitigation: 检测权限状态，拒绝后引导用户到设置页面开启权限

**[位置获取失败]**: GPS 信号弱或超时可能导致获取失败
→ Mitigation: 显示"获取中..."或"无信号"状态，不阻塞其他功能