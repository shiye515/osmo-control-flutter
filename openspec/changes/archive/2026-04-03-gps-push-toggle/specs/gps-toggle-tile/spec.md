## ADDED Requirements

### Requirement: GPS toggle tile on home screen
The system SHALL display a GPS toggle tile on the home screen status grid. The tile SHALL show the current GPS auto-push status and allow users to toggle the feature by tapping.

#### Scenario: GPS disabled
- **WHEN** GPS auto-push is disabled
- **THEN** tile shows "GPS" label with "未启用" value
- **AND** icon is gray location_off
- **AND** tapping the tile enables GPS auto-push

#### Scenario: GPS enabled and acquiring
- **WHEN** GPS auto-push is enabled
- **AND** location data is being acquired
- **THEN** tile shows GPS status with "获取中" value
- **AND** icon is primary colored location_searching
- **AND** tapping the tile disables GPS auto-push

#### Scenario: GPS enabled and location acquired
- **WHEN** GPS auto-push is enabled
- **AND** location data has been acquired
- **THEN** tile shows GPS status with active indicator
- **AND** icon is primary colored location_on
- **AND** tapping the tile disables GPS auto-push

## REMOVED Requirements

### Requirement: GPS settings page
**Reason**: GPS auto-push control has been integrated into home screen toggle tile. Separate page is no longer needed.
**Migration**: Use home screen GPS tile to toggle auto-push. Location details can be viewed in debug console logs if needed.

### Requirement: GPS navigation entry
**Reason**: GPS page removed, navigation entry no longer needed.
**Migration**: No alternative navigation needed - GPS control is now on home screen.