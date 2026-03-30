## 1. 协议扩展

- [x] 1.1 在 `dji_r_protocol.dart` 添加 `buildPowerModeCommand` 方法（CmdSet=0x00, CmdID=0x1A）
- [x] 1.2 添加 `buildWakeUpAdvData` 静态方法生成唤醒广播数据
- [x] 1.3 添加调试日志输出（发送帧 hex、参数值）

## 2. BLE 服务更新

- [x] 2.1 在 `ble_service.dart` 添加 `sendSleepCommand` 方法
- [x] 2.2 在 `ble_service.dart` 添加 `sendWakeCommand` 方法
- [x] 2.3 添加 `getWakeUpAdvData` 静态方法
- [x] 2.4 添加详细日志输出（命令发送前、发送后、响应接收）

## 3. 状态解析

- [x] 3.1 在相机状态解析中识别 `power_mode` 字段（偏移 28）
- [x] 3.2 添加 `_powerMode` 状态变量
- [x] 3.3 添加 `powerMode` getter 和状态流
- [x] 3.4 添加状态变化日志

## 4. Provider 集成

- [x] 4.1 在 `session_provider.dart` 添加 `sendSleep` 方法
- [x] 4.2 在 `session_provider.dart` 添加 `sendWake` 方法
- [x] 4.3 添加休眠状态管理

## 5. UI 实现

- [x] 5.1 在控制面板添加休眠按钮
- [x] 5.2 添加按钮状态控制（已连接时可用）
- [x] 5.3 添加操作反馈（成功/失败提示）

## 6. 测试验证

- [ ] 6.1 在真机上测试休眠命令发送
- [ ] 6.2 在真机上测试唤醒广播生成
- [ ] 6.3 验证日志输出完整性