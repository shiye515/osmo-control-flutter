## ADDED Requirements

### Requirement: GPS push failure tracking
The system SHALL track consecutive GPS push failures. When a push fails, the system SHALL increment a failure counter and log the failure.

#### Scenario: Push failure logged
- **WHEN** GPS push command fails (BLE write returns false)
- **THEN** system increments consecutive failure counter
- **AND** system logs the failure with warning level

#### Scenario: Push success resets counter
- **WHEN** GPS push command succeeds
- **THEN** system resets consecutive failure counter to 0

### Requirement: Maximum consecutive failures warning
The system SHALL log a warning when consecutive push failures reach the threshold of 3.

#### Scenario: Three consecutive failures
- **WHEN** consecutive push failures reach 3
- **THEN** system logs a warning message
- **AND** system continues attempting subsequent pushes

#### Scenario: Recovery after failures
- **WHEN** push succeeds after consecutive failures
- **THEN** failure counter resets to 0
- **AND** system continues normal operation

### Requirement: Push failure does not block GPS stream
The system SHALL NOT stop GPS acquisition when push failures occur. GPS position updates SHALL continue regardless of push success.

#### Scenario: GPS stream continues on push failure
- **WHEN** push fails
- **THEN** GPS position stream continues
- **AND** UI displays latest GPS position
- **AND** failure counter increments