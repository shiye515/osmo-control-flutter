# Connection Authentication Specification

## Requirements

### Requirement: Connection request command
The system SHALL send connection request (CmdSet=0x00, CmdID=0x19) to camera after BLE connection is established.

#### Scenario: First-time pairing
- **WHEN** connecting to a new camera for the first time
- **THEN** system sends connection request with verify_mode=1 and random verify_data

#### Scenario: Previously paired camera
- **WHEN** connecting to a previously paired camera
- **THEN** system sends connection request with verify_mode=0 and verify_data

### Requirement: Connection request payload
The system SHALL construct connection request payload with:
- device_id: 4 bytes (controller device ID)
- mac_addr_len: 1 byte (6)
- mac_addr: 16 bytes (controller MAC address, padded)
- fw_version: 4 bytes (0)
- conidx: 1 byte (reserved)
- verify_mode: 1 byte (0 or 1)
- verify_data: 2 bytes (verification code)
- reserved: 4 bytes

#### Scenario: Payload construction
- **WHEN** building connection request payload
- **THEN** payload is exactly 33 bytes

### Requirement: Connection acknowledgment
The system SHALL acknowledge camera's connection request within timeout period.

#### Scenario: Camera accepts connection
- **WHEN** camera sends connection request with verify_mode=2 and verify_data=0
- **THEN** system sends ack with camera number in reserved field

#### Scenario: Camera rejects connection
- **WHEN** camera sends connection request with verify_mode=2 and verify_data=1
- **THEN** system disconnects BLE and does not retry during current scan

### Requirement: Device ID mapping
The system SHALL recognize camera model from device_id in connection response:
- 0xFF33: Osmo Action 4
- 0xFF44: Osmo Action 5 Pro
- 0xFF55: Osmo Action 6
- 0xFF66: Osmo 360

#### Scenario: Identify camera model
- **WHEN** camera returns device_id=0xFF66
- **THEN** system identifies as Osmo 360

### Requirement: Connection timeout
The system SHALL timeout connection request after 10 seconds if no response received.

#### Scenario: Timeout handling
- **WHEN** camera does not respond within 10 seconds
- **THEN** system disconnects and reports connection failure

### Requirement: Sleep state detection during connection
The system SHALL detect camera sleep state during BLE connection.

#### Scenario: Detect sleeping camera
- **WHEN** BLE connection is established but camera is in sleep mode
- **THEN** system recognizes power_mode=3 from status push
- **AND** system logs the sleep state detection

#### Scenario: Wake sleeping camera
- **WHEN** camera is in sleep mode during connection
- **THEN** system can send wake command (power_mode=0)
- **AND** system logs the wake command

### Requirement: Save device on successful connection
The system SHALL save connected device ID and name to persistent storage after successful authentication.

#### Scenario: Save device after auth
- **WHEN** camera connection authentication succeeds
- **THEN** system saves device_id and device_name to SharedPreferences

#### Scenario: Save device name
- **WHEN** saving device to storage
- **THEN** system stores both device ID (MAC address) and display name