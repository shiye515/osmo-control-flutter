## MODIFIED Requirements

### Requirement: Status push parsing (1D02)
The system SHALL parse camera status push (CmdSet=0x1D, CmdID=0x02) payload containing:
- camera_mode: 1 byte
- camera_status: 1 byte (0=screen off, 1=live/idle, 2=playback, 3=recording, 5=pre-recording)
- video_resolution: 1 byte (see mapping table below)
- fps_idx: 1 byte (see mapping table below)
- EIS_mode: 1 byte
- record_time: 2 bytes (seconds)
- photo_ratio: 1 byte
- remain_capacity: 4 bytes (MB)
- remain_photo_num: 4 bytes
- remain_time: 4 bytes (seconds)
- power_mode: 1 byte (0=normal, 3=sleep)
- camera_bat_percentage: 1 byte (0-100%)

The system SHALL map video_resolution values:

| video_resolution | Display |
|------------------|---------|
| 10 | 1080P |
| 16 | 4K |
| 45 | 2.7K |
| 66 | 1080P 9:16 |
| 67 | 2.7K 9:16 |
| 95 | 2.7K 4:3 |
| 103 | 4K 4:3 |
| 109 | 4K 9:16 |

The system SHALL map fps_idx values:

| fps_idx | Frame Rate |
|---------|------------|
| 1 | 24fps |
| 2 | 25fps |
| 3 | 30fps |
| 4 | 48fps |
| 5 | 50fps |
| 6 | 60fps |
| 7 | 120fps |
| 8 | 240fps |
| 10 | 100fps |
| 19 | 200fps |

#### Scenario: Parse 1080P 60fps
- **WHEN** receiving status push with video_resolution=10 and fps_idx=6
- **THEN** system displays "1080P" and "60fps"

#### Scenario: Parse 4K 30fps
- **WHEN** receiving status push with video_resolution=16 and fps_idx=3
- **THEN** system displays "4K" and "30fps"

#### Scenario: Unknown resolution fallback
- **WHEN** receiving status push with unknown video_resolution value
- **THEN** system displays the raw value as string