## MODIFIED Requirements

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