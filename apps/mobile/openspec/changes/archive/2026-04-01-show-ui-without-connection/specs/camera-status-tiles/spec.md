## MODIFIED Requirements

### Requirement: Status tile component
The system SHALL display camera status as square tiles, 4 per row, even when no device is connected.

#### Scenario: Display battery tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows battery icon with "--" placeholder label

#### Scenario: Display storage tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows storage icon with "--" placeholder label

#### Scenario: Display recording time tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows "--:--:--" placeholder with timer icon

#### Scenario: Display resolution tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows video icon with "--" placeholder label

#### Scenario: Display frame rate tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows speed icon with "--" placeholder label

#### Scenario: Display EIS mode tile disconnected
- **WHEN** no camera is connected
- **THEN** tile shows stabilization icon with "--" placeholder label

### Requirement: Connection tile for disconnected state
The system SHALL display a connection tile indicating disconnected state when no device is connected.

#### Scenario: Connection tile shows disconnected
- **WHEN** no camera is connected
- **THEN** connection tile shows "未连接" label with Bluetooth icon
- **AND** tapping the tile opens device scan dialog

### Requirement: Record control tile disabled state
The system SHALL disable the record control tile when no device is connected.

#### Scenario: Record control tile disabled
- **WHEN** no camera is connected
- **THEN** record control tile shows gray/disabled appearance
- **AND** tapping the tile has no effect

### Requirement: Mode selector disabled state
The system SHALL disable the mode selector scroll wheel when no device is connected.

#### Scenario: Mode selector disabled
- **WHEN** no camera is connected
- **THEN** mode selector shows default mode (video)
- **AND** scroll wheel is disabled and cannot change mode