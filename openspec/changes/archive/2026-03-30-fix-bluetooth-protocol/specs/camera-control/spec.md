## ADDED Requirements

### Requirement: Recording control command
The system SHALL send recording control command (CmdSet=0x1D, CmdID=0x03) with:
- device_id: 4 bytes (camera device ID)
- record_ctrl: 1 byte (0=start, 1=stop)
- reserved: 4 bytes

#### Scenario: Start recording
- **WHEN** user presses record button while not recording
- **THEN** system sends record_ctrl=0

#### Scenario: Stop recording
- **WHEN** user presses record button while recording
- **THEN** system sends record_ctrl=1

### Requirement: Mode switch command
The system SHALL send mode switch command (CmdSet=0x1D, CmdID=0x04) with:
- device_id: 4 bytes (camera device ID)
- mode: 1 byte (target camera mode)
- reserved: 4 bytes

#### Scenario: Switch to photo mode
- **WHEN** user requests photo mode
- **THEN** system sends mode=0x05

#### Scenario: Switch to video mode
- **WHEN** user requests video mode
- **THEN** system sends mode=0x01

### Requirement: Power mode command
The system SHALL send power mode command (CmdSet=0x00, CmdID=0x1A) with power_mode byte (0=normal, 3=sleep).

#### Scenario: Sleep camera
- **WHEN** user requests camera sleep
- **THEN** system sends power_mode=3

#### Scenario: Wake camera
- **WHEN** camera is sleeping and user requests wake
- **THEN** system starts wake-up advertising for 2 seconds

### Requirement: Wake-up advertising
The system SHALL broadcast wake-up data for 2 seconds: [10, 0xFF, 'W','K','P', reversed_camera_MAC].

#### Scenario: Wake sleeping camera
- **WHEN** camera is sleeping within 30 minutes of last connection
- **THEN** system broadcasts wake-up data and waits for camera to reconnect

### Requirement: Key report command
The system SHALL send key report command (CmdSet=0x00, CmdID=0x11) with:
- key_code: 1 byte (0x01=record, 0x02=QS, 0x03=snapshot)
- mode: 1 byte (0x00=press/release, 0x01=event)
- key_value: 2 bytes (press state or event type)

#### Scenario: Short press record key
- **WHEN** user short presses record key
- **THEN** system sends key_code=0x01, mode=0x01, key_value=0x00

#### Scenario: Snapshot key for quick capture
- **WHEN** camera is sleeping and user presses snapshot key
- **THEN** system first sends wake-up broadcast, then sends key_code=0x03

### Requirement: Command acknowledgment handling
The system SHALL process command ack response with ret_code:
- 0x00: success
- 0x01: parse error
- 0x02: execution failed
- 0xFF: undefined error

#### Scenario: Command success
- **WHEN** camera returns ret_code=0x00
- **THEN** system reports operation successful

#### Scenario: Command failure
- **WHEN** camera returns ret_code=0x02
- **THEN** system reports operation failed to user