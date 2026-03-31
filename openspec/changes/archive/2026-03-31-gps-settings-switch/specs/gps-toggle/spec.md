## ADDED Requirements

### Requirement: GPS toggle switch
系统 SHALL 在 GPS 设置页面提供"启用 GPS"开关，控制是否从手机获取 GPS 数据。

#### Scenario: Enable GPS
- **WHEN** 用户开启"启用 GPS"开关
- **THEN** 系统请求位置权限
- **AND** 开始获取 GPS 位置数据

#### Scenario: Disable GPS
- **WHEN** 用户关闭"启用 GPS"开关
- **THEN** 系统停止 GPS 位置获取
- **AND** 清除当前位置数据

### Requirement: GPS permission handling
系统 SHALL 正确处理位置权限请求和状态。

#### Scenario: Permission granted
- **WHEN** 用户开启 GPS 且位置权限已授予
- **THEN** 系统立即开始获取 GPS 数据

#### Scenario: Permission denied
- **WHEN** 用户开启 GPS 但位置权限被拒绝
- **THEN** 系统显示权限被拒绝提示
- **AND** 开关保持关闭状态

#### Scenario: Permission request
- **WHEN** 用户开启 GPS 且未请求过权限
- **THEN** 系统弹出权限请求对话框

### Requirement: GPS state persistence
系统 SHALL 持久化 GPS 启用状态。

#### Scenario: Remember GPS state
- **WHEN** 用户设置 GPS 启用状态
- **THEN** 系统保存状态到本地存储
- **AND** 应用重启后恢复该状态

### Requirement: GPS toggle UI
系统 SHALL 在 GPS 设置页面显示 GPS 开关控件。

#### Scenario: Display GPS toggle
- **WHEN** 用户进入 GPS 设置页面
- **THEN** 页面顶部显示"启用 GPS"开关
- **AND** 开关下方显示当前 GPS 状态（启用/禁用）