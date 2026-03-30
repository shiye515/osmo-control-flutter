## 1. 存储模块

- [x] 1.1 添加 shared_preferences 依赖
- [x] 1.2 创建 DeviceMemoryService 服务类
- [x] 1.3 实现 saveDevice() 方法
- [x] 1.4 实现 getDevice() 方法
- [x] 1.5 实现 clearDevice() 方法

## 2. 自动连接逻辑

- [x] 2.1 在 SessionProvider 中集成 DeviceMemoryService
- [x] 2.2 连接成功后保存设备信息
- [x] 2.3 应用启动时检查记忆设备
- [x] 2.4 实现自动连接逻辑（带超时）
- [x] 2.5 连接失败时清除记忆并跳转扫描页

## 3. UI 更新

- [x] 3.1 在设置页添加"忘记设备"选项
- [x] 3.2 添加自动连接状态提示（可选）

## 4. 测试

- [x] 4.1 测试设备保存和读取
- [x] 4.2 测试自动连接流程
- [x] 4.3 测试清除记忆功能