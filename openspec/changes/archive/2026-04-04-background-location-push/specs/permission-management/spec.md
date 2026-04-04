## ADDED Requirements

### Requirement: Permission list display
The system SHALL display a list of all required permissions in the settings page, showing each permission's name, purpose, and current authorization status.

#### Scenario: View permission list
- **WHEN** user opens settings page
- **THEN** system displays a permission management section
- **AND** each permission shows: name, purpose description, authorization status

#### Scenario: Permission status indicators
- **WHEN** permission list is displayed
- **THEN** each permission shows appropriate status indicator
- **AND** statuses include: granted (green), denied (yellow), permanently denied (red)

### Requirement: Manual permission request
The system SHALL provide a button to manually request authorization for each permission that is not yet granted.

#### Scenario: Request denied permission
- **WHEN** user taps "Request Permission" button for a denied permission
- **THEN** system triggers the platform permission request dialog
- **AND** after user responds, status updates accordingly

#### Scenario: Request granted permission
- **WHEN** permission is already granted
- **THEN** "Request Permission" button is hidden or disabled
- **AND** status shows "Granted" with green indicator

### Requirement: Open system settings for permanently denied
The system SHALL provide a button to open system app settings when permission is permanently denied.

#### Scenario: Permanently denied permission
- **WHEN** permission status is permanently denied
- **THEN** system shows "Open Settings" button
- **AND** tapping button opens system app settings page
- **AND** system shows guidance message about enabling permission in settings

#### Scenario: User returns from settings
- **WHEN** user returns to app after changing permission in system settings
- **THEN** system refreshes permission status
- **AND** displays updated authorization state

### Requirement: Required permissions list
The system SHALL display the following permissions with their purpose descriptions:

#### Scenario: Bluetooth permission entry
- **WHEN** permission list is displayed
- **THEN** bluetooth permission shows with purpose: "连接 Osmo 设备"

#### Scenario: Location (while in use) permission entry
- **WHEN** permission list is displayed
- **THEN** location permission shows with purpose: "获取 GPS 位置"

#### Scenario: Location (background/always) permission entry
- **WHEN** permission list is displayed
- **THEN** background location permission shows with purpose: "锁屏后继续获取位置"

### Requirement: Permission refresh on app resume
The system SHALL refresh permission status when app resumes from background.

#### Scenario: App resume permission check
- **WHEN** user returns to app from another app or settings
- **THEN** system checks current permission states
- **AND** updates permission list display if status changed