## ADDED Requirements

### Requirement: Save device on successful connection
The system SHALL save connected device ID and name to persistent storage after successful authentication.

#### Scenario: Save device after auth
- **WHEN** camera connection authentication succeeds
- **THEN** system saves device_id and device_name to SharedPreferences

#### Scenario: Save device name
- **WHEN** saving device to storage
- **THEN** system stores both device ID (MAC address) and display name