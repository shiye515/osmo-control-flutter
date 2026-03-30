## 1. 文档准备

- [x] 1.1 创建 `docs/ble_protocol.md` 文档，记录 DJI R SDK 协议完整规范
- [x] 1.2 在文档中记录帧结构、CRC 算法、命令集、连接流程

## 2. 协议层实现

- [x] 2.1 创建 `apps/mobile/lib/api/dji_protocol.dart` 实现 DJI R SDK 协议帧封装
- [x] 2.2 实现 CRC-16 校验算法（SOF 到 SEQ 段）
- [x] 2.3 实现 CRC-32 校验算法（SOF 到 DATA 段）
- [x] 2.4 实现序列号生成器（全局递增，模 65536）
- [x] 2.5 实现 frame encoder：将 CmdSet/CmdID/payload 转为完整帧
- [x] 2.6 实现 frame decoder：解析接收帧并提取 payload
- [x] 2.7 创建 `apps/mobile/lib/utils/dji_crc.dart` CRC 工具类

## 3. 数据层实现

- [x] 3.1 创建 `apps/mobile/lib/api/dji_data_processor.dart` DATA 段处理器
- [x] 3.2 创建 `apps/mobile/lib/models/connection_request.dart` 连接请求模型
- [x] 3.3 创建 `apps/mobile/lib/models/camera_status.dart` 相机状态模型
- [x] 3.4 创建 `apps/mobile/lib/models/gps_data.dart` GPS 数据模型
- [x] 3.5 创建 `apps/mobile/lib/models/recording_control.dart` 拍录控制模型
- [x] 3.6 创建 `apps/mobile/lib/models/mode_switch.dart` 模式切换模型
- [x] 3.7 实现 DATA 段的 creator/parser 函数

## 4. BLE 服务更新

- [x] 4.1 修改 `app_constants.dart`：Write UUID 从 FFF6 改为 FFF5，Notify UUID 从 FFF7 改为 FFF4
- [x] 4.2 修改 `ble_service.dart`：使用新的 UUID
- [x] 4.3 添加连接请求发送逻辑到 `ble_service.dart`
- [x] 4.4 添加连接应答处理逻辑
- [x] 4.5 添加休眠唤醒广播发送逻辑

## 5. 连接鉴权流程

- [x] 5.1 实现发送连接请求命令（CmdSet=0x00, CmdID=0x19）
- [x] 5.2 实现接收相机连接应答
- [x] 5.3 实现接收相机连接请求（verify_mode=2）
- [x] 5.4 实现发送连接应答（包含相机编号）
- [x] 5.5 实现 device_id 映射识别相机型号
- [x] 5.6 添加连接超时处理（10秒）

## 6. 相机状态订阅

- [x] 6.1 实现发送状态订阅命令（CmdSet=0x1D, CmdID=0x05）
- [x] 6.2 实现 1D02 状态推送解析（camera_mode, camera_status 等）
- [x] 6.3 实现 1D06 扩展状态推送解析（mode_name, mode_param）
- [x] 6.4 更新 `session_provider.dart` 集成状态订阅
- [x] 6.5 添加状态变化通知机制

## 7. 相机控制命令

- [x] 7.1 实现拍录控制命令（CmdSet=0x1D, CmdID=0x03）
- [x] 7.2 实现模式切换命令（CmdSet=0x1D, CmdID=0x04）
- [x] 7.3 实现电源模式命令（CmdSet=0x00, CmdID=0x1A）
- [x] 7.4 实现按键上报命令（CmdSet=0x00, CmdID=0x11）
- [x] 7.5 更新控制按钮调用新的命令函数

## 8. GPS 推送

- [x] 8.1 实现 GPS 数据推送命令（CmdSet=0x00, CmdID=0x17）
- [x] 8.2 实现坐标编码（value = actual * 10^7）
- [x] 8.3 实现高度编码（单位 mm）
- [x] 8.4 实现速度编码（单位 cm/s，float）
- [x] 8.5 更新 `gps_provider.dart` 使用新命令

## 9. Provider 集成

- [x] 9.1 更新 `session_provider.dart` 连接流程
- [x] 9.2 更新 `session_provider.dart` 控制命令发送
- [x] 9.3 添加连接状态管理（未连接/鉴权中/已连接）
- [x] 9.4 更新相机状态 UI 数据绑定

## 10. 清理与测试

- [x] 10.1 删除旧的 DUML 协议代码（`protocol_codec.dart`）
- [x] 10.2 删除旧的常量定义（dumlHeaderByte, dumlVersion）
- [ ] 10.3 编写单元测试验证帧封装正确性
- [ ] 10.4 编写单元测试验证 CRC 算法正确性
- [ ] 10.5 在真机上测试完整连接流程
- [ ] 10.6 在真机上测试控制命令