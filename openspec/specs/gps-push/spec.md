## ADDED Requirements

### Requirement: GPS push command
The system SHALL send GPS data push command (CmdSet=0x00, CmdID=0x17) with payload:
- year_month_day: 4 bytes (year*10000 + month*100 + day)
- hour_minute_second: 4 bytes ((hour+8)*10000 + minute*100 + second)
- gps_longitude: 4 bytes (actual value * 10^7)
- gps_latitude: 4 bytes (actual value * 10^7)
- height: 4 bytes (mm)
- speed_to_north: 4 bytes (float, cm/s)
- speed_to_east: 4 bytes (float, cm/s)
- speed_to_downward: 4 bytes (float, cm/s)
- vertical_accuracy_estimate: 4 bytes (mm)
- horizontal_accuracy_estimate: 4 bytes (mm)
- speed_accuracy_estimate: 4 bytes (cm/s)
- satellite_number: 4 bytes

#### Scenario: Push GPS coordinates
- **WHEN** GPS provides latitude=31.2304, longitude=121.4737
- **THEN** system sends gps_latitude=312304000, gps_longitude=1214737000

#### Scenario: Push altitude
- **WHEN** GPS provides altitude=10.5 meters
- **THEN** system sends height=10500 (mm)

### Requirement: GPS push frequency
The system SHALL push GPS data at configurable frequency (default 1Hz, max 10Hz).

#### Scenario: Periodic GPS push
- **WHEN** GPS frequency is set to 1Hz
- **THEN** system pushes GPS data every 1 second

### Requirement: GPS coordinate encoding
The system SHALL encode coordinates as signed 32-bit integers with value = actual * 10^7.

#### Scenario: Negative longitude
- **WHEN** longitude is -122.4194
- **THEN** gps_longitude = -1224194000 (as signed int32)

### Requirement: GPS acknowledgment optional
The system MAY ignore GPS push acknowledgment (CmdType ack type = 1 means ack optional).

#### Scenario: No ack received
- **WHEN** GPS push sent and no ack received
- **THEN** system continues GPS push without error