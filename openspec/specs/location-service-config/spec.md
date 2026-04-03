## MODIFIED Requirements

### Requirement: LocationService startPositionStream parameters
The system SHALL use the distanceFilter parameter in LocationSettings when startPositionStream is called. This allows controlling GPS update frequency based on distance traveled.

#### Scenario: Distance filter applied
- **WHEN** startPositionStream is called with distanceFilter=10
- **THEN** LocationSettings uses distanceFilter=10
- **AND** GPS updates only occur when device moves 10+ meters

#### Scenario: Zero distance filter for real-time updates
- **WHEN** startPositionStream is called with distanceFilter=0 (default)
- **THEN** GPS updates occur at maximum frequency
- **AND** every position change triggers an update

### Requirement: Remove unused intervalMs parameter
The system SHALL remove the intervalMs parameter from startPositionStream since Geolocator's LocationSettings does not support interval configuration on all platforms.

#### Scenario: startPositionStream simplified signature
- **WHEN** startPositionStream is called
- **THEN** only distanceFilter parameter is accepted
- **AND** method signature is `startPositionStream({int distanceFilter = 0})`