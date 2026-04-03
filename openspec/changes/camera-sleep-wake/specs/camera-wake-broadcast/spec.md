## ADDED Requirements

### Requirement: Wake camera via BLE advertisement
The system SHALL wake a sleeping camera by broadcasting BLE advertisement data for 2 seconds. The advertisement data SHALL follow DJI R SDK protocol format: `[10, 0xFF, 'W', 'K', 'P', MAC_address_reversed]`.

#### Scenario: Wake sleeping camera on Android
- **WHEN** user taps the wake button
- **AND** platform is Android
- **THEN** system starts BLE advertisement with wake-up data
- **AND** advertisement continues for 2 seconds
- **AND** system waits for camera to reconnect

#### Scenario: Wake not supported on iOS
- **WHEN** user taps the wake button
- **AND** platform is iOS
- **THEN** system shows a message that wake is not supported
- **AND** suggests user to manually press camera power button

### Requirement: Sleep and wake buttons in debug console
The system SHALL provide sleep and wake buttons in the debug console page for testing purposes.

#### Scenario: Sleep button displayed
- **WHEN** user views the debug console page
- **AND** camera is connected
- **THEN** system displays a sleep button

#### Scenario: Wake button displayed
- **WHEN** user views the debug console page
- **THEN** system displays a wake button

#### Scenario: Tap sleep button
- **WHEN** user taps the sleep button
- **THEN** system sends sleep command to camera
- **AND** camera enters sleep mode
- **AND** BLE connection is lost

#### Scenario: Tap wake button
- **WHEN** user taps the wake button
- **THEN** system triggers wake broadcast
- **AND** waits for camera to reconnect