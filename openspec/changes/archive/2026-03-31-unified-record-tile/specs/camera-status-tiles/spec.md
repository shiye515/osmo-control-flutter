## ADDED Requirements

### Requirement: Recording control tile
系统 SHALL 提供一个智能录制控制磁贴，根据相机状态自动切换功能。

#### Scenario: Stop recording
- **WHEN** 相机正在录制
- **THEN** 磁贴显示停止图标和"停止"文字
- **AND** 点击后发送停止录制命令

#### Scenario: Start recording in video mode
- **WHEN** 相机未录制且处于视频模式
- **THEN** 磁贴显示录制图标和"录制"文字
- **AND** 点击后发送开始录制命令

#### Scenario: Take photo in photo mode
- **WHEN** 相机处于拍照模式
- **THEN** 磁贴显示拍照图标和"拍照"文字
- **AND** 点击后发送拍照命令