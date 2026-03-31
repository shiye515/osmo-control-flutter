## MODIFIED Requirements

### Requirement: GPS push frequency
The system SHALL push GPS data at configurable frequency with fixed options: 2s, 5s, or 10s intervals.

#### Scenario: Push every 2 seconds
- **WHEN** GPS frequency is set to 2s option
- **THEN** system pushes GPS data every 2 seconds (0.5Hz)

#### Scenario: Push every 5 seconds
- **WHEN** GPS frequency is set to 5s option
- **THEN** system pushes GPS data every 5 seconds (0.2Hz)

#### Scenario: Push every 10 seconds
- **WHEN** GPS frequency is set to 10s option
- **THEN** system pushes GPS data every 10 seconds (0.1Hz)

### Requirement: GPS auto-push control
The system SHALL start GPS acquisition and push automatically when auto-push is enabled.

#### Scenario: Enable auto-push
- **WHEN** user enables auto-push toggle
- **THEN** system starts GPS acquisition
- **AND** system begins pushing GPS data at selected frequency

#### Scenario: Disable auto-push
- **WHEN** user disables auto-push toggle
- **THEN** system stops pushing GPS data
- **AND** GPS acquisition continues for position display

## REMOVED Requirements

### Requirement: Manual GPS enable toggle
**Reason**: GPS acquisition is now controlled by auto-push toggle
**Migration**: Use auto-push toggle to control GPS acquisition and push

### Requirement: Push now button
**Reason**: Manual push is redundant when auto-push is available
**Migration**: Enable auto-push to continuously push GPS data