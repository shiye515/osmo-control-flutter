## MODIFIED Requirements

### Requirement: setAutoPushEnabled returns Future
The system SHALL return `Future<void>` from `setAutoPushEnabled` method instead of `void`. This allows callers to await the operation and handle potential errors.

#### Scenario: Await setAutoPushEnabled
- **WHEN** user enables auto-push
- **THEN** UI can await the operation completion
- **AND** UI can handle GPS start failure

#### Scenario: setAutoPushEnabled triggers GPS start
- **WHEN** setAutoPushEnabled(true) is called
- **AND** GPS is not currently enabled
- **THEN** method calls setGpsEnabled(true) internally
- **AND** method returns after GPS stream starts

### Requirement: setAutoPushEnabled async error handling
The system SHALL propagate errors from GPS start operation through setAutoPushEnabled Future.

#### Scenario: GPS permission denied
- **WHEN** setAutoPushEnabled(true) is called
- **AND** GPS permission is denied
- **THEN** method returns successfully but GPS stream does not start
- **AND** autoPushEnabled is set to true