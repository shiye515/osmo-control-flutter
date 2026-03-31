## ADDED Requirements

### Requirement: Location permission handling
系统 SHALL 正确请求和处理位置权限。

#### Scenario: Request permission
- **WHEN** 应用首次请求位置
- **THEN** 系统显示权限请求对话框
- **AND** 用户授权后可获取位置

#### Scenario: Permission denied
- **WHEN** 用户拒绝位置权限
- **THEN** 系统显示提示信息
- **AND** 引导用户到设置页面

### Requirement: Get current location
系统 SHALL 获取设备当前 GPS 位置。

#### Scenario: Get position success
- **WHEN** 权限已授权且定位服务开启
- **THEN** 系统返回当前经纬度和高度

#### Scenario: Location service disabled
- **WHEN** 设备定位服务未开启
- **THEN** 系统提示用户开启定位服务

### Requirement: Location stream
系统 SHALL 提供持续的位置更新流。

#### Scenario: Position updates
- **WHEN** 应用在前台运行
- **THEN** 系统定期推送位置更新（每秒一次）
- **AND** 包含经度、纬度、高度、精度、速度等信息