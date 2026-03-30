## MODIFIED Requirements

### Requirement: Mode list display
模式选择器 SHALL 根据设备类型动态显示支持的相机模式。

#### Scenario: Osmo Action 4 mode selector
- **WHEN** 连接设备为 Osmo Action 4
- **THEN** 滚轮选择器仅显示 4 个模式：慢动作、视频、静止延时、拍照

#### Scenario: Other device mode selector
- **WHEN** 连接设备非 Osmo Action 4
- **THEN** 滚轮选择器显示所有 7 个模式