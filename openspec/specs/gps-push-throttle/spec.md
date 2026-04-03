## ADDED Requirements

### Requirement: GPS push throttling
The system SHALL throttle GPS push commands to a maximum frequency of 1 Hz (one push per second). When a new GPS position is received within the throttle window, the system SHALL skip the push and wait for the next valid window.

#### Scenario: Push within throttle window
- **WHEN** GPS position is received 500ms after the last push
- **AND** auto-push is enabled
- **THEN** system skips the push
- **AND** waits for throttle window to expire

#### Scenario: Push after throttle window
- **WHEN** GPS position is received 1000ms or more after the last push
- **AND** auto-push is enabled
- **THEN** system pushes the GPS data to camera

#### Scenario: First push after enabling auto-push
- **WHEN** user enables auto-push
- **AND** GPS position is available
- **THEN** system pushes immediately without throttle delay

### Requirement: Throttle configuration
The system SHALL use a default throttle interval of 1000ms. The interval MAY be configurable in future versions but SHALL be hardcoded initially.

#### Scenario: Default throttle interval
- **WHEN** system initializes GpsProvider
- **THEN** throttle interval is set to 1000ms