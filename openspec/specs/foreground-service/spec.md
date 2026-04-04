## ADDED Requirements

### Requirement: Android foreground service
The system SHALL automatically run a foreground service on Android when app starts, to maintain app activity while screen is locked.

#### Scenario: Foreground service started on launch
- **WHEN** app launches on Android
- **THEN** system starts foreground service with location type
- **AND** system shows persistent notification indicating location acquisition

#### Scenario: Foreground service notification
- **WHEN** foreground service is running
- **THEN** notification displays current status (GPS active, connection status)
- **AND** notification is non-dismissible while service runs
- **AND** tapping notification opens the app

#### Scenario: Foreground service stopped
- **WHEN** user intentionally closes the app (swipe away from recent apps)
- **THEN** foreground service stops
- **AND** notification is removed

### Requirement: BLE connection maintenance
The system SHALL maintain Bluetooth connection while foreground service is running.

#### Scenario: BLE active during background
- **WHEN** foreground service is running with BLE connection
- **THEN** BLE connection remains active
- **AND** GPS data can be pushed to device while screen locked

#### Scenario: BLE reconnection in background
- **WHEN** BLE connection drops during background mode
- **THEN** system attempts automatic reconnection
- **AND** notification shows reconnecting status

### Requirement: Service lifecycle management
The system SHALL properly manage foreground service lifecycle across app states.

#### Scenario: App minimized with service running
- **WHEN** user minimizes app
- **THEN** foreground service continues running
- **AND** location updates and BLE communication continue

#### Scenario: App crashed and restarted
- **WHEN** app crashes while foreground service running
- **THEN** on restart, system automatically starts foreground service
- **AND** background location acquisition resumes