## Requirements

### Requirement: Status tile component
The system SHALL display camera status as square tiles, 4 per row, even when no device is connected.

#### Scenario: Display battery tile
- **WHEN** camera battery is 85%
- **THEN** tile shows battery icon with "85%" label

#### Scenario: Display battery tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows battery icon with "--" placeholder label

#### Scenario: Display storage tile
- **WHEN** SD card has 32GB remaining
- **THEN** tile shows storage icon with "32GB" label

#### Scenario: Display storage tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows storage icon with "--" placeholder label

#### Scenario: Display recording time tile
- **WHEN** recording time is 5 minutes 23 seconds
- **THEN** tile shows "00:05:23" with timer icon

#### Scenario: Display recording time tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows "--:--:--" placeholder with timer icon

#### Scenario: Display camera mode tile
- **WHEN** camera is in video mode
- **THEN** tile shows video icon with "视频" label

#### Scenario: Display resolution tile
- **WHEN** video_resolution is 16 (4K)
- **THEN** tile shows video icon with "4K" label

#### Scenario: Display resolution tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows video icon with "--" placeholder label

#### Scenario: Display frame rate tile
- **WHEN** fps_idx is 6 (60fps)
- **THEN** tile shows speed icon with "60fps" label

#### Scenario: Display frame rate tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows speed icon with "--" placeholder label

#### Scenario: Display EIS mode tile
- **WHEN** eis_mode is 1 (RS)
- **THEN** tile shows stabilization icon with "RS" label

#### Scenario: Display EIS mode tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows stabilization icon with "--" placeholder label

### Requirement: Resolution tile
The system SHALL display camera resolution as a separate status tile.

#### Scenario: Display 4K resolution
- **WHEN** video_resolution is 16 (4K)
- **THEN** tile shows video icon with "4K" label

#### Scenario: Display 1080P resolution
- **WHEN** video_resolution is 10 (1080P)
- **THEN** tile shows video icon with "1080P" label

### Requirement: Frame rate tile
The system SHALL display camera frame rate as a separate status tile.

#### Scenario: Display 60fps
- **WHEN** fps_idx is 6 (60fps)
- **THEN** tile shows speed icon with "60fps" label

#### Scenario: Display 30fps
- **WHEN** fps_idx is 3 (30fps)
- **THEN** tile shows speed icon with "30fps" label

### Requirement: EIS mode tile
The system SHALL display camera EIS (Electronic Image Stabilization) mode as a status tile.

#### Scenario: Display RS mode
- **WHEN** eis_mode is 1 (RS)
- **THEN** tile shows stabilization icon with "RS" label

#### Scenario: Display HS mode
- **WHEN** eis_mode is 2 (HS)
- **THEN** tile shows stabilization icon with "HS" label

#### Scenario: Display EIS off
- **WHEN** eis_mode is 0 (OFF)
- **THEN** tile shows stabilization icon with "OFF" label

### Requirement: Real-time status updates
The system SHALL update status tiles when camera status changes.

#### Scenario: Battery drops
- **WHEN** battery changes from 85% to 84%
- **THEN** battery tile updates to show "84%"

#### Scenario: Recording starts
- **WHEN** camera starts recording
- **THEN** camera status tile changes to "录制中"
- **AND** recording time tile appears with "00:00:00"

### Requirement: Status tile layout
The system SHALL display status tiles in a grid at the top of the workbench page.

#### Scenario: Two rows of tiles
- **WHEN** camera is connected
- **THEN** top 8 status tiles are displayed
- **AND** tiles are arranged in 2 rows of 4

### Requirement: Status tile styling
Each status tile SHALL be square with icon and label.

#### Scenario: Tile dimensions
- **WHEN** status tiles are rendered
- **THEN** each tile is approximately square
- **AND** has equal width and height
- **AND** shows an icon at top and label at bottom

### Requirement: Connection tile for disconnected state
The system SHALL display a connection tile indicating disconnected state when no device is connected.

#### Scenario: Connection tile shows disconnected
- **WHEN** no camera is connected
- **THEN** connection tile shows "未连接" label with Bluetooth icon
- **AND** tapping the tile opens device scan dialog

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

### Requirement: Record control tile disabled state
The system SHALL disable the record control tile when no device is connected.

#### Scenario: Record control tile disabled
- **WHEN** no camera is connected
- **THEN** record control tile shows gray/disabled appearance
- **AND** tapping the tile has no effect

### Requirement: Mode selector disabled state
The system SHALL disable the mode selector scroll wheel when no device is connected.

#### Scenario: Mode selector disabled
- **WHEN** no camera is connected
- **THEN** mode selector shows default mode (video)
- **AND** scroll wheel is disabled and cannot change mode