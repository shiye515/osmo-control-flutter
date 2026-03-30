# device-mode-filter Specification

## Purpose
根据设备类型动态过滤相机模式列表，避免用户切换到设备不支持的模式。

## Requirements

### Requirement: Device type identification
系统 SHALL 根据相机 device_id 识别设备型号。

#### Scenario: Identify Osmo Action 4
- **WHEN** device_id = 0xFF33
- **THEN** 系统识别为 Osmo Action 4

#### Scenario: Identify Osmo Action 5 Pro
- **WHEN** device_id = 0xFF44
- **THEN** 系统识别为 Osmo Action 5 Pro

#### Scenario: Identify unknown device
- **WHEN** device_id 不匹配任何已知型号
- **THEN** 系统识别为 unknown 类型

### Requirement: Mode filtering by device type
系统 SHALL 根据设备类型返回支持的相机模式列表。

#### Scenario: Osmo Action 4 modes
- **WHEN** 设备为 Osmo Action 4
- **THEN** 返回模式列表仅包含：慢动作(0x00)、视频(0x01)、静止延时(0x02)、拍照(0x05)

#### Scenario: Other device modes
- **WHEN** 设备非 Osmo Action 4
- **THEN** 返回完整模式列表：慢动作、视频、静止延时、拍照、运动延时、低光视频、人物跟随