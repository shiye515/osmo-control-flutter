## Requirements

### Requirement: GPS data model
The system SHALL maintain GPS data with the following fields:
- latitude (double)
- longitude (double)
- altitude (double)
- accuracy (double) - horizontal accuracy in meters
- speed (double) - speed magnitude in m/s
- speedNorth (double) - northward speed component in m/s
- speedEast (double) - eastward speed component in m/s
- verticalAccuracy (double?) - vertical accuracy in meters, nullable
- speedAccuracy (double?) - speed accuracy in m/s, nullable
- heading (double) - direction in degrees
- timestamp (DateTime)

#### Scenario: Create GPS data with all fields
- **WHEN** GPS provides latitude=31.2304, longitude=121.4737, altitude=10.5, speed=5.0, heading=45°
- **THEN** system creates GpsPointModel with speedNorth≈3.54, speedEast≈3.54

#### Scenario: Handle missing optional fields
- **WHEN** device does not report verticalAccuracy or speedAccuracy
- **THEN** these fields are null and display shows "--"

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

### Requirement: GPS auto-push control
The system SHALL start GPS acquisition and push automatically when auto-push is enabled. When a new GPS position is received, the system SHALL immediately push the data to the camera.

#### Scenario: Enable auto-push
- **WHEN** user enables auto-push toggle
- **THEN** system starts GPS acquisition
- **AND** system pushes GPS data immediately when new position is received

#### Scenario: Disable auto-push
- **WHEN** user disables auto-push toggle
- **THEN** system stops pushing GPS data
- **AND** GPS acquisition continues for position display

#### Scenario: Real-time push on GPS update
- **WHEN** GPS provides a new position update
- **AND** auto-push is enabled
- **THEN** system immediately pushes the GPS data to camera

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