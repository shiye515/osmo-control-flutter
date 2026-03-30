## ADDED Requirements

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