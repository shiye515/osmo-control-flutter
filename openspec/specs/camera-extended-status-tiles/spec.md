## ADDED Requirements

### Requirement: User mode display
The system SHALL display the current user mode (custom mode) when it is not the default mode (0). The display SHALL show "Custom 1" to "Custom 5" for user modes 1-5.

#### Scenario: User mode is default
- **WHEN** userMode is 0
- **THEN** system does not display user mode tile

#### Scenario: User mode is custom
- **WHEN** userMode is 2
- **THEN** system displays "Custom 2" or localized equivalent

### Requirement: Remaining photo count display
The system SHALL display remaining photo count when camera is in photo mode (0x05). The display SHALL show the number of photos that can be taken.

#### Scenario: Photo mode with remaining photos
- **WHEN** camera mode is 0x05 (photo)
- **AND** remainPhotoNum is 1500
- **THEN** system displays "1500" photos remaining

#### Scenario: Non-photo mode
- **WHEN** camera mode is not photo mode
- **THEN** remaining photo count tile is not displayed

### Requirement: Loop recording display
The system SHALL display loop recording duration when camera is in video mode (0x01) and loop recording is enabled. The display SHALL convert seconds to readable format (OFF/5m/20m/1h/MAX).

#### Scenario: Loop recording off
- **WHEN** camera mode is video
- **AND** loopRecordSecs is 0
- **THEN** system displays "OFF" or does not show the tile

#### Scenario: Loop recording 5 minutes
- **WHEN** camera mode is video
- **AND** loopRecordSecs is 300
- **THEN** system displays "5m"

#### Scenario: Loop recording max
- **WHEN** camera mode is video
- **AND** loopRecordSecs is 65535
- **THEN** system displays "MAX"

### Requirement: Photo countdown display
The system SHALL display photo countdown when camera is in photo mode and countdown is active. The display SHALL show remaining time in seconds.

#### Scenario: Photo countdown active
- **WHEN** camera mode is photo
- **AND** photoCountdownMs is 5000 (5 seconds)
- **THEN** system displays "5s" countdown

### Requirement: Timelapse parameters display
The system SHALL display timelapse interval and duration when camera is in timelapse mode (0x02 or 0x0A).

#### Scenario: Static timelapse with interval
- **WHEN** camera mode is 0x02 (static timelapse)
- **AND** timelapseInterval is 50 (5.0 seconds)
- **THEN** system displays "5.0s interval"

#### Scenario: Motion timelapse auto
- **WHEN** camera mode is 0x0A (motion timelapse)
- **AND** timelapseInterval is 0
- **THEN** system displays "Auto"