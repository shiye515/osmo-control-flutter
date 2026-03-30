## ADDED Requirements

### Requirement: Status subscription command
The system SHALL send status subscription command (CmdSet=0x1D, CmdID=0x05) after successful connection with:
- push_mode: 1 byte (3=periodic + on-change)
- push_freq: 1 byte (20=2Hz, fixed)
- reserved: 4 bytes

#### Scenario: Subscribe after connection
- **WHEN** connection authentication succeeds
- **THEN** system sends push_mode=3, push_freq=20

### Requirement: Status push parsing (1D02)
The system SHALL parse camera status push (CmdSet=0x1D, CmdID=0x02) payload containing:
- camera_mode: 1 byte
- camera_status: 1 byte (0=screen off, 1=live/idle, 2=playback, 3=recording, 5=pre-recording)
- video_resolution: 1 byte
- fps_idx: 1 byte
- EIS_mode: 1 byte
- record_time: 2 bytes (seconds)
- photo_ratio: 1 byte
- remain_capacity: 4 bytes (MB)
- remain_photo_num: 4 bytes
- remain_time: 4 bytes (seconds)
- power_mode: 1 byte (0=normal, 3=sleep)
- camera_bat_percentage: 1 byte (0-100%)

#### Scenario: Parse recording status
- **WHEN** receiving status push with camera_status=3
- **THEN** system reports camera is recording

#### Scenario: Parse battery level
- **WHEN** receiving status push with camera_bat_percentage=85
- **THEN** system displays 85% battery

### Requirement: Extended status parsing (1D06)
The system SHALL parse extended status push (CmdSet=0x1D, CmdID=0x06) for camera_mode > 0x34 containing:
- type_mode_name: 1 byte (0x01)
- mode_name_length: 1 byte
- mode_name: 21 bytes (ASCII string)
- type_mode_param: 1 byte (0x02)
- mode_param_length: 1 byte
- mode_param: 21 bytes (ASCII string)

#### Scenario: Parse Osmo 360 mode name
- **WHEN** receiving 1D06 push with mode_name="Panorama Video"
- **THEN** system displays mode name as "Panorama Video"

### Requirement: Mode value mapping
The system SHALL map camera_mode values:
- 0x00: Slow Motion
- 0x01: Video
- 0x02: Static Timelapse
- 0x05: Photo
- 0x0A: Motion Timelapse (Hyperlapse)
- 0x28: Low Light Video
- 0x34: Person Follow
- 0x38-0x4A: Osmo 360 specific modes

#### Scenario: Display video mode
- **WHEN** camera_mode=0x01
- **THEN** system displays "Video" mode

### Requirement: Status update notification
The system SHALL notify UI of status changes via Provider change notification.

#### Scenario: Recording time update
- **WHEN** receiving status push with new record_time value
- **THEN** UI updates displayed recording time