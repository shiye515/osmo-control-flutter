## Why

当前项目中已有 `sleep()` 和 `wake()` 方法，但唤醒实现存在问题：相机休眠后无法接收 BLE 数据，因此 `sendWakeCommand()` 无效。根据 DJI 协议文档，唤醒休眠相机需要通过 BLE 广播特定数据 2 秒。

## What Changes

- 修正唤醒流程：使用 BLE 广播唤醒数据，而非发送命令
- 添加休眠状态 UI 展示（已在状态磁帖中显示）
- 添加休眠/唤醒按钮到调试台页面（方便测试）
- 注意：iOS 平台可能不支持广播功能，需要平台判断

## Capabilities

### New Capabilities
- `camera-wake-broadcast`: 通过 BLE 广播唤醒休眠相机

### Modified Capabilities
- `camera-sleep-control`: 休眠功能已实现，唤醒需要改用广播方式

## Impact

- `ble_service.dart`: 添加 BLE 广播唤醒功能
- `session_provider.dart`: 修改 `wake()` 方法使用广播唤醒
- `debug_console_view.dart`: 添加休眠/唤醒按钮