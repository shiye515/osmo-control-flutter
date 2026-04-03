## ADDED Requirements

### Requirement: Connected device display in scan dialog
The system SHALL display the currently connected device at the top of the scan dialog when a device is connected. The display SHALL show the device name and provide a disconnect button.

#### Scenario: Connected device shown
- **WHEN** a device is currently connected
- **AND** user opens the scan dialog
- **THEN** system displays the connected device at the top of the dialog
- **AND** system shows device name and connection status
- **AND** system shows a disconnect button

#### Scenario: No connected device
- **WHEN** no device is connected
- **AND** user opens the scan dialog
- **THEN** connected device section is not displayed

### Requirement: Disconnect button functionality
The system SHALL provide a disconnect button next to the connected device. When tapped, the system SHALL disconnect from the device and update the UI.

#### Scenario: Disconnect button tapped
- **WHEN** user taps the disconnect button
- **THEN** system disconnects from the device
- **AND** connected device section is removed from the dialog
- **AND** scan results list is updated

### Requirement: Remove auto-connect banner
The system SHALL NOT display the "Searching for..." auto-connect banner. The auto-connect functionality SHALL continue to work in the background without visual indication.

#### Scenario: Auto-connect continues silently
- **WHEN** a remembered device is found during scan
- **THEN** system connects automatically without showing a banner
- **AND** dialog closes on successful connection