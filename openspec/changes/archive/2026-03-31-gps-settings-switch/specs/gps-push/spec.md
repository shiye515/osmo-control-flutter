## ADDED Requirements

### Requirement: GPS enabled state control
系统 SHALL 通过 `gpsEnabled` 状态控制 GPS 数据获取。

#### Scenario: Start location stream when enabled
- **WHEN** gpsEnabled 设置为 true
- **THEN** 系统调用 LocationService.startPositionStream()
- **AND** 位置数据更新到 GpsProvider.lastGpsPoint

#### Scenario: Stop location stream when disabled
- **WHEN** gpsEnabled 设置为 false
- **THEN** 系统调用 LocationService.stopPositionStream()
- **AND** GpsProvider.lastGpsPoint 设置为 null

### Requirement: GPS provider integration
系统 SHALL 在 GpsProvider 中集成 LocationService 和 gpsEnabled 状态。

#### Scenario: LocationService integration
- **WHEN** GpsProvider 初始化
- **THEN** GpsProvider 持有 LocationService 实例
- **AND** 可控制 LocationService 的启停

#### Scenario: GPS state change triggers location service
- **WHEN** setGpsEnabled 被调用
- **THEN** GpsProvider 根据参数启动或停止 LocationService