# mode-scroll-selector Specification

## Purpose
TBD - created by archiving change scroll-mode-selector. Update Purpose after archive.
## Requirements
### Requirement: Scroll wheel mode selector
The system SHALL provide a scroll wheel interface for selecting camera modes, similar to iOS time picker style.

#### Scenario: Display mode list
- **WHEN** mode selector is shown
- **THEN** system displays available modes in a scrollable wheel
- **AND** current mode is centered in the wheel

#### Scenario: Scroll through modes
- **WHEN** user scrolls up or down
- **THEN** wheel rotates to show adjacent modes
- **AND** selected mode snaps to center when scrolling stops

### Requirement: Auto-send on scroll end
The system SHALL send mode switch command after scrolling stops.

#### Scenario: Send command after scroll ends
- **WHEN** user stops scrolling for 500ms
- **THEN** system sends switch mode command with selected mode value

#### Scenario: Cancel pending command on new scroll
- **WHEN** user starts scrolling while a send is pending
- **THEN** system cancels the pending send
- **AND** waits for scroll to stop again

### Requirement: Mode display format
The system SHALL display each mode with icon and name.

#### Scenario: Mode item display
- **WHEN** displaying a mode in the wheel
- **THEN** system shows mode icon and Chinese name
- **AND** uses different opacity for center vs edge items

### Requirement: Mode list display
模式选择器 SHALL 根据设备类型动态显示支持的相机模式。

#### Scenario: Osmo Action 4 mode selector
- **WHEN** 连接设备为 Osmo Action 4
- **THEN** 滚轮选择器仅显示 4 个模式：慢动作、视频、静止延时、拍照

#### Scenario: Other device mode selector
- **WHEN** 连接设备非 Osmo Action 4
- **THEN** 滚轮选择器显示所有 7 个模式

### Requirement: Supported modes
The system SHALL support the following camera modes:
- 0x00: 慢动作 (Slow Motion)
- 0x01: 视频 (Video)
- 0x02: 静止延时 (Static Timelapse)
- 0x05: 拍照 (Photo)
- 0x0A: 运动延时 (Motion Timelapse)
- 0x28: 低光视频 (Low Light Video)
- 0x34: 人物跟随 (Person Follow)

Osmo Action 4 仅支持前 4 种模式。

#### Scenario: Unknown mode value
- **WHEN** current mode is not in supported list
- **THEN** system displays "未知模式" (Unknown Mode)
- **AND** still allows sending the mode switch command

