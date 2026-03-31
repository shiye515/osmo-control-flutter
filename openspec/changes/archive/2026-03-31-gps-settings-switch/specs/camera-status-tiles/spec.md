## ADDED Requirements

### Requirement: GPS data tile
系统 SHALL 在工作台显示 GPS 数据磁贴，显示当前经纬度信息。

#### Scenario: Display GPS tile when enabled
- **WHEN** GPS 功能已启用且有位置数据
- **THEN** 显示 GPS 磁贴
- **AND** 磁贴显示当前位置图标
- **AND** 显示经纬度数值

#### Scenario: Display GPS tile when disabled
- **WHEN** GPS 功能未启用
- **THEN** 显示 GPS 磁贴但内容为"未启用"
- **AND** 磁贴样式为灰色/禁用状态

#### Scenario: Display GPS tile when no data
- **WHEN** GPS 功能已启用但暂无位置数据
- **THEN** 显示 GPS 磁贴但内容为"获取中..."

#### Scenario: GPS tile updates on location change
- **WHEN** GPS 位置数据更新
- **THEN** GPS 磁贴内容实时更新显示新位置