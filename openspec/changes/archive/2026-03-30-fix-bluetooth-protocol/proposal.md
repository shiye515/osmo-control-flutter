## Why

当前 Flutter 应用无法控制 DJI Osmo 设备，因为蓝牙协议实现与官方 DJI R SDK 协议完全不兼容。通过对比官方文档与现有代码，发现协议格式、UUID、命令集均存在严重错误，导致设备完全无法响应任何控制指令。

## What Changes

- **BREAKING**: 完全重写蓝牙协议实现，从 DUML 协议 (SOF=0x55) 切换到 DJI R SDK 协议 (SOF=0xAA)
- **BREAKING**: 修正 BLE 特征值 UUID：Write 从 FFF6 改为 FFF5，Notify 从 FFF7 改为 FFF4
- 新增连接请求鉴权流程 (CmdSet=0x00, CmdID=0x19)，包含首次配对和已配对两种模式
- 新增相机状态订阅功能 (CmdSet=0x1D, CmdID=0x05)，支持 2Hz 周期推送
- 修正所有控制命令的 CmdSet/CmdID：
  - 拍录控制：从 (0x01, 0x4B) 改为 (0x1D, 0x03)
  - 模式切换：从 (0x01, 0x34) 改为 (0x1D, 0x04)
  - GPS 推送：从 (0x04, 0x08) 改为 (0x00, 0x17)
  - 电源模式：使用 (0x00, 0x1A)
- 新增按键上报功能 (CmdSet=0x00, CmdID=0x11)，支持短按/长按/双击等事件
- 新增休眠唤醒广播机制
- 将蓝牙协议文档写入项目文档，便于后续维护

## Capabilities

### New Capabilities

- `dji-r-sdk-protocol`: DJI R SDK 协议帧的封装与解析，包含 CRC-16/CRC-32 校验、序列号管理、帧结构定义
- `connection-auth`: 连接请求鉴权流程，包含首次配对、已配对自动连接、校验码处理
- `camera-control`: 相机控制命令集（拍录控制、模式切换、电源模式、按键上报）
- `camera-status-subscription`: 相机状态订阅与推送解析，支持周期性推送和状态变化触发
- `gps-push`: GPS 数据推送功能，按照官方协议格式构建数据帧

### Modified Capabilities

无（当前实现完全错误，不涉及对现有正确功能的修改）

## Impact

- `apps/mobile/lib/api/ble_service.dart`: 修正 UUID，添加连接请求流程
- `apps/mobile/lib/api/protocol_codec.dart`: 完全重写协议编解码
- `apps/mobile/lib/config/app_constants.dart`: 更新 UUID 和协议常量
- `apps/mobile/lib/providers/session_provider.dart`: 集成连接请求和状态订阅
- 新增 `apps/mobile/lib/models/` 下的协议数据结构模型
- 新增 `docs/ble_protocol.md`: 蓝牙协议文档