## ADDED Requirements

### Requirement: Protocol frame structure
The system SHALL implement DJI R SDK protocol frame with the following structure:
- SOF: 1 byte, fixed 0xAA
- Ver/Length: 2 bytes, [15:10] version (default 0), [9:0] frame length (LSB first)
- CmdType: 1 byte, [4:0] ack type, [5] frame type (0=command, 1=ack)
- ENC: 1 byte, encryption type (0=none)
- RES: 3 bytes, reserved
- SEQ: 2 bytes, sequence number
- CRC-16: 2 bytes, checksum of bytes 0-9
- DATA: variable bytes, starting with CmdSet/CmdID
- CRC-32: 4 bytes, checksum of bytes 0 to end of DATA

#### Scenario: Build command frame
- **WHEN** building a command with CmdSet=0x1D, CmdID=0x03, payload=[0x00]
- **THEN** system generates a valid DJI R SDK frame starting with 0xAA

#### Scenario: Parse response frame
- **WHEN** receiving a valid DJI R SDK frame from camera
- **THEN** system extracts CmdSet, CmdID, and payload bytes

### Requirement: CRC-16 checksum
The system SHALL compute CRC-16 checksum for the first 10 bytes (SOF to SEQ) using the DJI custom algorithm.

#### Scenario: CRC-16 computation
- **WHEN** computing CRC-16 for bytes [0xAA, 0x1B, 0x00, ...]
- **THEN** result matches DJI R SDK specification

### Requirement: CRC-32 checksum
The system SHALL compute CRC-32 checksum for all bytes from SOF to end of DATA using the DJI custom algorithm.

#### Scenario: CRC-32 computation
- **WHEN** computing CRC-32 for the entire frame minus last 4 bytes
- **THEN** result matches DJI R SDK specification

### Requirement: Sequence number management
The system SHALL maintain a global sequence number counter, incrementing modulo 65536 for each command frame sent.

#### Scenario: Sequence increment
- **WHEN** sending two consecutive command frames
- **THEN** second frame has SEQ value = first frame SEQ + 1 (mod 65536)

#### Scenario: Sequence matching for ack
- **WHEN** receiving an ack frame
- **THEN** SEQ matches the corresponding command frame SEQ

### Requirement: DATA segment structure
The system SHALL construct DATA segment with CmdSet (1 byte), CmdID (1 byte), followed by payload bytes.

#### Scenario: DATA segment construction
- **WHEN** building DATA for command (CmdSet=0x00, CmdID=0x19)
- **THEN** DATA starts with bytes [0x00, 0x19, ...]

### Requirement: Little-endian storage
The system SHALL store all multi-byte values in little-endian format (LSB first).

#### Scenario: Little-endian length
- **WHEN** frame length is 27 (0x001B)
- **THEN** Ver/Length bytes are [0x1B, 0x00]