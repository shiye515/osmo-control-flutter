## MODIFIED Requirements

### Requirement: GPS auto-push control
The system SHALL provide GPS auto-push control via the home screen toggle tile. Users SHALL be able to enable/disable GPS auto-push by tapping the GPS tile in the status grid.

#### Scenario: Toggle GPS auto-push
- **WHEN** user taps the GPS toggle tile
- **THEN** system toggles autoPushEnabled state
- **AND** tile updates to reflect new state
- **AND** if enabled, system starts GPS acquisition and push

## REMOVED Requirements

### Requirement: GPS settings page with detailed info
**Reason**: GPS auto-push control moved to home screen tile. Detailed position/speed/accuracy info removed from UI.
**Migration**: GPS toggle is now on home screen. Use debug console to see GPS logs if detailed info needed.