## Why

当前GPS获取与推送逻辑存在若干设计与实现问题，可能导致BLE通信压力、数据丢失、异常处理不当等风险。这些问题在长时间运行或高频率GPS更新场景下尤为明显，需要在代码层面进行优化以确保稳定性和可靠性。

## What Changes

- **修复 setAutoPushEnabled 返回类型**: 从 `void async` 改为 `Future<void>`,使调用者能够正确等待操作完成并处理异常
- **添加GPS推送节流机制**: 引入推送频率限制，避免BLE带宽压力和电量过度消耗
- **修复 timestamp 时区处理**: 明确GPS时间戳的时区转换逻辑，确保DJI协议要求的UTC+8格式正确
- **添加推送失败处理**: 实现失败日志记录和可选的重试队列机制
- **清理未使用参数**: 移除或启用 LocationService 中被忽略的 distanceFilter 和 intervalMs 参数
- **卫星数量动态估算**: 根据accuracy值动态估算卫星数量，替代硬编码常量

## Capabilities

### New Capabilities

- `gps-push-throttle`: GPS推送频率节流机制，控制BLE通信频率
- `gps-push-retry`: GPS推送失败处理与重试队列机制

### Modified Capabilities

- `gps-provider-state`: GpsProvider状态管理方法的返回类型变更（setAutoPushEnabled从void改为Future<void>)
- `location-service-config`: LocationService配置参数的实际使用

## Impact

- **代码文件**:
  - `gps_provider.dart`: 核心变更文件
  - `location_service.dart`: 配置参数启用
  - `session_provider.dart`: 推送逻辑优化
  - `dji_r_protocol.dart`: 时间戳处理修正
- **API变更**: `GpsProvider.setAutoPushEnabled` 返回类型从 `void` 变为 `Future<void>`（**BREAKING** - 调用方需处理异步）
- **依赖**: 无新增外部依赖
- **向后兼容**: 现有功能行为不变，仅优化内部逻辑