## ADDED Requirements

### Requirement: Background location acquisition
The system SHALL automatically enable background GPS location acquisition when app starts, allowing location updates while device is locked or app is in background state.

#### Scenario: Location acquired while screen locked
- **WHEN** user locks phone screen with app running
- **THEN** system continues to receive GPS position updates at configured interval

#### Scenario: Location acquired while app in background
- **WHEN** user switches to another app
- **THEN** system continues to receive GPS position updates

#### Scenario: App starts with background mode
- **WHEN** app launches
- **THEN** system automatically requests always/background location permission
- **AND** starts background location service if permissions granted

### Requirement: Automatic permission request
The system SHALL request always/background location permission automatically on app launch.

#### Scenario: Permission granted
- **WHEN** app launches and user grants always location permission
- **THEN** background location service starts automatically
- **AND** GPS data continues to be acquired in background

#### Scenario: Permission denied
- **WHEN** app launches and user denies always location permission
- **THEN** system shows guidance to enable permission in system settings
- **AND** continues to request permission until granted (with user confirmation)

#### Scenario: Permission granted after denial
- **WHEN** user grants permission after previously denying
- **THEN** background location service starts immediately