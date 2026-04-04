## 1. 研究和验证

- [x] 1.1 检查 flutter_blue_plus 是否支持 BLE 广播 API
  - **结论**: flutter_blue_plus 仅支持 Central 模式，不支持 Peripheral/广播功能
  - **替代方案**: 使用 `flutter_ble_peripheral` 包（v2.1.0）实现广播
- [x] 1.2 验证 Android 和 iOS 平台的广播能力差异
  - **结论**: flutter_ble_peripheral 支持 Android、iOS、macOS、Windows
  - **iOS 注意**: iOS 对广播数据有特定限制，不支持自定义 manufacturer data 广播

## 2. 实现唤醒广播功能

- [x] 2.0 添加 flutter_ble_peripheral 依赖到 pubspec.yaml
- [x] 2.1 在 `ble_service.dart` 添加 `startWakeUpBroadcast()` 方法
- [x] 2.2 在 `ble_service.dart` 添加平台判断和错误处理
- [x] 2.3 修改 `session_provider.dart` 的 `wake()` 方法使用广播唤醒
- [x] 2.4 添加 BLUETOOTH_ADVERTISE 权限到 AndroidManifest.xml
- [x] 2.5 修复 MAC 地址获取：使用 device.remoteId.str 而非 platformName
- [x] 2.6 添加运行时权限检查和蓝牙状态检查

## 3. 添加休眠/唤醒磁贴

- [x] 3.1 在 `status_tiles_grid.dart` 添加休眠磁贴（仅连接时显示）
- [x] 3.2 在 `status_tiles_grid.dart` 添加唤醒磁贴（互斥显示）
- [x] 3.3 从调试台移除休眠/唤醒按钮
- [x] 3.4 iOS 点击唤醒显示不支持提示

## 4. 自动重连功能

- [x] 4.1 添加断开连接事件监听
- [x] 4.2 保存最后连接设备的 MAC 地址
- [x] 4.3 添加 `scanAndConnectToMac()` 方法
- [x] 4.4 唤醒后自动扫描并连接设备

## 5. 测试验证

- [x] 5.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 5.2 手动测试：休眠相机后尝试唤醒并自动重连