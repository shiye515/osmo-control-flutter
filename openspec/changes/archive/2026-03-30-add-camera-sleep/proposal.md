## Why

当前应用无法控制相机进入休眠状态，也无法在相机休眠后通过 BLE 广播唤醒相机。这导致用户需要手动操作相机电源按钮来唤醒设备，影响使用体验。

根据 DJI R SDK 文档，相机支持通过 BLE 命令控制休眠/唤醒，可以实现远程电源管理功能。

## What Changes

- 添加休眠命令发送功能（CmdSet=0x00, CmdID=0x1A）
- 添加唤醒广播发送功能（WKP 广播数据）
- 添加休眠状态检测（电源模式状态解析）
- 在 UI 中添加休眠/唤醒控制按钮
- 添加详细调试日志便于问题排查

## Capabilities

### New Capabilities

- `camera-sleep-control`: 相机休眠控制功能，包括发送休眠命令、发送唤醒广播、状态检测

### Modified Capabilities

- `connection-auth`: 扩展连接状态管理，支持休眠状态识别

## Impact

- **BLE 服务**: 添加休眠命令发送和唤醒广播功能
- **Session Provider**: 添加休眠状态管理
- **UI**: 添加休眠/唤醒控制按钮
- **调试日志**: 添加详细的命令发送和响应日志