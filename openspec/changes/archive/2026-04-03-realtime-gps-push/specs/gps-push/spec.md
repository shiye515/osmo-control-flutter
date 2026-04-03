## REMOVED Requirements

### Requirement: GPS push frequency
**Reason**: 不再使用定时推送，改为实时推送（每次 GPS 更新时推送）
**Migration**: 移除频率选择 UI 和相关逻辑

## MODIFIED Requirements

### Requirement: GPS auto-push control
The system SHALL start GPS acquisition and push automatically when auto-push is enabled. When a new GPS position is received, the system SHALL immediately push the data to the camera.

#### Scenario: Enable auto-push
- **WHEN** user enables auto-push toggle
- **THEN** system starts GPS acquisition
- **AND** system pushes GPS data immediately when new position is received

#### Scenario: Disable auto-push
- **WHEN** user disables auto-push toggle
- **THEN** system stops pushing GPS data
- **AND** GPS acquisition continues for position display

#### Scenario: Real-time push on GPS update
- **WHEN** GPS provides a new position update
- **AND** auto-push is enabled
- **THEN** system immediately pushes the GPS data to camera