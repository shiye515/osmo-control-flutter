## Why

用户每次重启应用都需要重新扫描并连接设备，体验繁琐。记住上次连接的设备并在启动时自动重连，可以显著提升用户体验。

## What Changes

- 保存上次成功连接的设备 ID 和名称到本地存储
- 应用启动时检查是否有已保存的设备
- 自动尝试连接已保存的设备
- 连接失败时跳转到扫描页面
- 提供清除记忆设备的功能

## Capabilities

### New Capabilities

- `device-memory`: 设备记忆功能，保存和读取上次连接的设备信息

### Modified Capabilities

- `connection-auth`: 连接流程增加自动重连逻辑

## Impact

- 新增设备记忆存储模块 (使用 SharedPreferences)
- 修改应用启动流程，增加自动连接逻辑
- 修改 SessionProvider，增加记忆设备管理
- 可能需要修改扫描页面，显示"正在自动连接..."提示