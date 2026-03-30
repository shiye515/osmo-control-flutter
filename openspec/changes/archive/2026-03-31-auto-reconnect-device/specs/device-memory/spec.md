## ADDED Requirements

### Requirement: Device memory storage
The system SHALL persist the last connected device ID and name using SharedPreferences.

#### Scenario: Save device after successful connection
- **WHEN** device connection succeeds
- **THEN** system saves device ID and name to SharedPreferences

#### Scenario: Clear device memory
- **WHEN** user chooses to forget the device
- **THEN** system removes stored device ID and name

### Requirement: Device memory retrieval
The system SHALL retrieve stored device information on app startup.

#### Scenario: Load stored device on startup
- **WHEN** app starts
- **THEN** system checks SharedPreferences for stored device ID

#### Scenario: No stored device
- **WHEN** no device is stored
- **THEN** system proceeds with normal scan flow

### Requirement: Auto-reconnect on startup
The system SHALL automatically attempt to connect to the remembered device.

#### Scenario: Auto-connect to remembered device
- **WHEN** stored device ID exists and device is available
- **THEN** system attempts to connect without user intervention

#### Scenario: Auto-connect timeout
- **WHEN** auto-connect attempt exceeds 5 seconds
- **THEN** system cancels connection and shows scan page

#### Scenario: Auto-connect failure
- **WHEN** auto-connect fails
- **THEN** system shows scan page with option to retry