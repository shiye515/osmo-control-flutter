## Context

当前GPS推送流程如下：
```
Geolocator.positionStream → LocationService → GpsProvider → SessionProvider → BleProvider → DJI设备
```

问题分析：
1. `setAutoPushEnabled` 返回 `void async`，调用者无法等待操作完成
2. GPS流频率约1Hz，每次都触发BLE推送，无节流机制
3. 推送失败只记录日志，数据丢失
4. `LocationService.startPositionStream` 参数被忽略
5. 时间戳时区处理可能不正确

约束：
- Flutter Provider 模式，需要 notifyListeners 通知UI更新
- BLE通信带宽有限，需要控制推送频率
- DJI协议要求时间戳为UTC+8格式

## Goals / Non-Goals

**Goals:**
- 修复API返回类型，使调用者能正确处理异步操作
- 添加推送节流，控制BLE通信频率不超过 2Hz
- 启用LocationService配置参数
- 添加推送失败日志和简单重试机制
- 明确时间戳时区处理

**Non-Goals:**
- 不改变GPS获取频率（由Geolocator控制）
- 不添加复杂的离线缓存队列（超出当前需求范围）
- 不修改UI层代码（除必要的异步处理）

## Decisions

### 1. 节流实现方式

**选择**: 时间窗口节流（Time-based throttling）

**理由**: 简单有效，记录上次推送时间，距离上次推送超过阈值才允许新推送。

**替代方案**:
- Debounce: 不适合，会延迟推送，GPS数据需要实时性
- 距离变化阈值: 可作为后续增强，但当前时间节流足够

**实现**:
```dart
DateTime? _lastPushTime;
static const _minPushIntervalMs = 500; // 0.5秒

if (_autoPushEnabled && _shouldPush()) {
  _sessionProvider?.pushGps(_lastGpsPoint!);
  _lastPushTime = DateTime.now();
}

bool _shouldPush() {
  if (_lastPushTime == null) return true;
  return DateTime.now().difference(_lastPushTime!).inMilliseconds >= _minPushIntervalMs;
}
```

### 2. 失败处理策略

**选择**: 简单日志记录 + 最近失败计数

**理由**: 避免复杂队列机制，保留失败状态供UI展示。

**替代方案**:
- 重试队列: 复杂度高，需要存储管理
- 无限重试: 可能阻塞后续推送

**实现**:
```dart
int _consecutivePushFailures = 0;
static const _maxConsecutiveFailures = 3;

// 推送失败时
_consecutivePushFailures++;
if (_consecutivePushFailures >= _maxConsecutiveFailures) {
  _log.warning('GPS push consecutive failures: $_consecutivePushFailures');
}

// 推送成功时重置
_consecutivePushFailures = 0;
```

### 3. 时区处理

**选择**: 假设timestamp为本地时间，协议层转换为UTC+8

**理由**: `DateTime.now()` 和 Geolocator 返回的时间戳通常是本地时间。

**实现**:
```dart
// dji_r_protocol.dart 保持现有逻辑，添加注释说明
// 注意: timestamp 应为本地时间，此处转换为UTC+8
```

### 4. LocationService参数

**选择**: 移除未使用的参数，保持简洁

**理由**: 当前 `distanceFilter=0` 已满足实时推送需求，暴露未实现参数反而造成误解。

## Risks / Trade-offs

| 风险                       | 缓解措施                                              |
| -------------------------- | ----------------------------------------------------- |
| 节流导致部分GPS数据丢失    | 1秒间隔足够满足DJI设备需求，丢失的数据对录像影响有限  |
| 推送失败无重试导致数据丢失 | 记录失败状态，用户可手动重试；后续可增强为队列        |
| API返回类型变更影响调用方  | 仅一处调用(gps_settings_view.dart)，简单改为await即可 |

## Open Questions

- 是否需要配置化节流间隔？否
- 推送失败时是否需要UI提示？否