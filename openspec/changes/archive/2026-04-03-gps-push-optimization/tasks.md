## 1. GpsProvider API修复

- [x] 1.1 修改 `setAutoPushEnabled` 方法签名：从 `void async` 改为 `Future<void>`
- [x] 1.2 在 `gps_settings_view.dart` 中添加 `await` 处理异步操作

## 2. GPS推送节流机制

- [x] 2.1 在 `GpsProvider` 中添加 `_lastPushTime` 和 `_minPushIntervalMs` 常量
- [x] 2.2 实现 `_shouldPush()` 方法判断是否满足推送间隔
- [x] 2.3 在 `_locationSubscription` 回调中集成节流逻辑

## 3. GPS推送失败处理

- [x] 3.1 在 `GpsProvider` 中添加 `_consecutivePushFailures` 计数器
- [x] 3.2 修改 `_startLocationStream` 回调，根据 `pushGps` 返回值更新计数器
- [x] 3.3 在 `SessionProvider.pushGps` 中返回推送结果（成功/失败）
- [x] 3.4 添加连续失败达到阈值时的警告日志

## 4. LocationService参数优化

- [x] 4.1 移除 `startPositionStream` 中未使用的 `intervalMs` 参数
- [x] 4.2 启用 `distanceFilter` 参数，传递给 `LocationSettings`

## 5. 时区处理注释

- [x] 5.1 在 `dji_r_protocol.dart` 的 `buildPushGps` 方法中添加时区转换注释说明

## 6. 测试验证

- [x] 6.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 6.2 手动测试：启用自动推送，验证节流生效（观察日志频率）
- [ ] 6.3 手动测试：断开BLE连接后验证推送失败计数和日志