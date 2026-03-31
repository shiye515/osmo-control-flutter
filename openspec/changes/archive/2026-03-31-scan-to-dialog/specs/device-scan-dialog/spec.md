## ADDED Requirements

### Requirement: Device scan dialog component
系统 SHALL 提供设备扫描弹窗组件，替代独立页面。

#### Scenario: Show scan dialog
- **WHEN** 调用 showDeviceScanDialog
- **THEN** 系统显示底部弹窗
- **AND** 弹窗包含设备列表和扫描状态

#### Scenario: Close scan dialog
- **WHEN** 用户下拉或点击关闭按钮
- **THEN** 弹窗关闭

### Requirement: Auto show dialog on startup
系统 SHALL 在应用启动未连接设备时自动弹出扫描弹窗。

#### Scenario: No device connected on startup
- **WHEN** 应用启动且未连接设备
- **THEN** 自动弹出扫描弹窗

#### Scenario: Device connected on startup
- **WHEN** 应用启动且已自动连接设备
- **THEN** 不弹出扫描弹窗

### Requirement: Show dialog from connection tile
系统 SHALL 在点击连接状态磁贴时弹出扫描弹窗。

#### Scenario: Tap connection tile
- **WHEN** 用户点击连接状态磁贴
- **THEN** 弹出扫描弹窗
- **AND** 显示当前连接设备和扫描到的其他设备

### Requirement: Disconnect from dialog
系统 SHALL 允许从扫描弹窗中断开当前设备连接。

#### Scenario: Disconnect current device
- **WHEN** 用户在弹窗中点击断开连接
- **THEN** 断开当前设备连接
- **AND** 弹窗保持打开以连接新设备