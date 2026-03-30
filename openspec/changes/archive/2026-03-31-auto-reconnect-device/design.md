## Context

Flutter 移动应用使用 Provider 进行状态管理，BleService 处理蓝牙连接。当前每次启动应用都需要用户手动扫描并连接设备。使用 SharedPreferences 可以持久化存储设备信息。

## Goals / Non-Goals

**Goals:**
- 保存上次成功连接的设备 ID 和名称
- 应用启动时自动尝试连接已记忆的设备
- 连接失败时引导用户到扫描页面
- 提供清除记忆的功能

**Non-Goals:**
- 保存多个设备（只记忆最后一个）
- 保存设备的其他状态（如设置参数）

## Decisions

### 1. 存储方案

**决定**: 使用 SharedPreferences 存储设备 ID 和名称

**理由**:
- 简单轻量，适合存储少量字符串
- Flutter 原生支持，无需额外依赖
- 异步 API，不阻塞 UI

**存储结构**:
```dart
// Keys
const String kLastDeviceId = 'last_device_id';
const String kLastDeviceName = 'last_device_name';
```

### 2. 自动连接时机

**决定**: 在 SessionProvider 初始化时触发自动连接

**流程**:
```
App启动 → SessionProvider初始化 → 检查是否有记忆设备
  ↓ 有                              ↓ 无
尝试连接 → 成功/失败              正常显示扫描入口
```

### 3. 连接超时处理

**决定**: 自动连接设置较短的超时时间 (5秒)

**理由**: 快速失败，避免用户长时间等待

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|---------|
| 设备不可用时用户等待 | 使用较短超时 (5秒) |
| 用户想连接不同设备 | 在设置中提供"忘记设备"选项 |
| 存储读取失败 | 使用默认值，不影响正常流程 |