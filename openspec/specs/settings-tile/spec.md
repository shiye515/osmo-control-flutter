## ADDED Requirements

### Requirement: Settings tile on home screen
The system SHALL display a settings tile in the status grid at the 4th position of the first row. The tile SHALL show a settings icon and label, and navigate to the settings page when tapped.

#### Scenario: Settings tile displayed
- **WHEN** user views the home screen status grid
- **THEN** system displays a settings tile at position 4 of the first row
- **AND** tile shows settings icon and label

#### Scenario: Navigate to settings
- **WHEN** user taps the settings tile
- **THEN** system navigates to the settings page

### Requirement: Debug console entry in settings
The system SHALL provide a debug console entry in the settings page. The entry SHALL navigate to the debug console page when tapped.

#### Scenario: Debug console entry displayed
- **WHEN** user views the settings page
- **THEN** system displays a debug console entry with icon and label

#### Scenario: Navigate to debug console
- **WHEN** user taps the debug console entry
- **THEN** system navigates to the debug console page

### Requirement: About section using AboutListTile
The system SHALL use Flutter's AboutListTile component to display application about information in the settings page.

#### Scenario: About section displayed
- **WHEN** user views the settings page
- **THEN** system displays an AboutListTile with application name, version, and copyright

#### Scenario: View licenses
- **WHEN** user taps the AboutListTile
- **THEN** system shows the licenses page

## REMOVED Requirements

### Requirement: Bottom navigation bar
**Reason**: Navigation simplified to single-page mode with settings tile on home screen.
**Migration**: Use settings tile for settings, debug console entry moved to settings page.