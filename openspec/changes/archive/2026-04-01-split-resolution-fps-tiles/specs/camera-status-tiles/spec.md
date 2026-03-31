## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Status tile component
The system SHALL display camera status as square tiles, 4 per row.

#### Scenario: Display battery tile
- **WHEN** camera battery is 85%
- **THEN** tile shows battery icon with "85%" label

#### Scenario: Display storage tile
- **WHEN** SD card has 32GB remaining
- **THEN** tile shows storage icon with "32GB" label

#### Scenario: Display recording time tile
- **WHEN** recording time is 5 minutes 23 seconds
- **THEN** tile shows "00:05:23" with timer icon

#### Scenario: Display camera mode tile
- **WHEN** camera is in video mode
- **THEN** tile shows video icon with "视频" label

#### Scenario: Display resolution tile
- **WHEN** video_resolution is 16 (4K)
- **THEN** tile shows video icon with "4K" label

#### Scenario: Display frame rate tile
- **WHEN** fps_idx is 6 (60fps)
- **THEN** tile shows speed icon with "60fps" label

#### Scenario: Display EIS mode tile
- **WHEN** eis_mode is 1 (RS)
- **THEN** tile shows stabilization icon with "RS" label