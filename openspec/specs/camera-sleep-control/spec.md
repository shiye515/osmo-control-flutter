## ADDED Requirements

### Requirement: Send sleep command to camera
The system SHALL send a power mode command to put the camera into sleep mode.

#### Scenario: Send sleep command successfully
- **WHEN** user requests to put camera to sleep
- **THEN** system sends DJI R SDK frame with CmdSet=0x00, CmdID=0x1A, Payload=[0x03]
- **AND** system logs the sent frame in hex format

#### Scenario: Send wake command successfully
- **WHEN** user requests to wake the camera
- **THEN** system sends DJI R SDK frame with CmdSet=0x00, CmdID=0x1A, Payload=[0x00]
- **AND** system logs the sent frame in hex format

### Requirement: Generate wake-up advertisement data
The system SHALL generate wake-up advertisement data to wake a sleeping camera.

#### Scenario: Generate wake-up broadcast
- **WHEN** system needs to wake a sleeping camera
- **THEN** system generates advertisement data in format [10, 0xFF, 'W','K','P', MAC(reversed)]
- **AND** system logs the generated data

#### Scenario: Wake-up broadcast with valid MAC
- **WHEN** camera MAC address is "12:34:56:78:9A:BC"
- **THEN** generated wake-up data is [10, 0xFF, 0x57, 0x4B, 0x50, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12]

### Requirement: Parse power mode status
The system SHALL parse power mode status from camera state push (0x1D, 0x02).

#### Scenario: Detect sleep state
- **WHEN** camera status push contains power_mode=3
- **THEN** system recognizes camera is in sleep mode
- **AND** system logs the detected power mode

#### Scenario: Detect normal state
- **WHEN** camera status push contains power_mode=0
- **THEN** system recognizes camera is in normal mode

### Requirement: Debug logging for sleep control
The system SHALL output detailed logs for sleep control operations.

#### Scenario: Log command parameters
- **WHEN** sending sleep/wake command
- **THEN** system logs the power_mode value before sending

#### Scenario: Log raw frame data
- **WHEN** sending or receiving frames
- **THEN** system logs the complete frame in hex format

#### Scenario: Log state changes
- **WHEN** power mode state changes
- **THEN** system logs the previous and new state