## ADDED Requirements

### Requirement: Complete status model
The system SHALL parse and expose all status push fields in a complete CameraStatusModel.

#### Scenario: Parse all 1D02 fields
- **WHEN** receiving status push payload
- **THEN** system extracts all fields including:
  - real_time_countdown: 2 bytes
  - timelapse_interval: 2 bytes
  - timelapse_duration: 2 bytes
  - user_mode: 1 byte
  - camera_mode_next_flag: 1 byte
  - temp_over: 1 byte
  - photo_countdown_ms: 4 bytes
  - loop_record_sends: 2 bytes

#### Scenario: Temperature status parsing
- **WHEN** receiving status push with temp_over=1
- **THEN** system reports camera is overheating
- **AND** UI displays temperature warning

### Requirement: Status change events
The system SHALL emit status change events when any field changes.

#### Scenario: Resolution change event
- **WHEN** video_resolution changes from 4K to 1080p
- **THEN** status stream emits new resolution value

#### Scenario: Storage low event
- **WHEN** remain_capacity drops below 1GB
- **THEN** status stream includes low storage flag