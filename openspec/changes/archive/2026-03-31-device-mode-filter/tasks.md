## 1. 设备类型定义

- [x] 1.1 在 camera_modes.dart 中添加设备类型枚举（DeviceType）
- [x] 1.2 添加设备 device_id 常量映射（OsmoAction4=0xFF33 等）
- [x] 1.3 添加 getDeviceType(int deviceId) 判断函数

## 2. 模式过滤实现

- [x] 2.1 添加 getSupportedModes(int deviceId) 函数
- [x] 2.2 定义 Osmo Action 4 专属模式列表（仅 4 种模式）
- [x] 2.3 其他设备返回完整模式列表

## 3. 集成到 UI

- [x] 3.1 SessionProvider 添加 cameraDeviceId getter
- [x] 3.2 ModeScrollSelector 接收 deviceId 参数
- [x] 3.3 WorkbenchView 传递 deviceId 到 ModeScrollSelector

## 4. 测试

- [x] 4.1 测试 Osmo Action 4 设备显示 4 种模式
- [x] 4.2 测试其他设备显示全部模式
- [x] 4.3 测试未识别设备显示全部模式