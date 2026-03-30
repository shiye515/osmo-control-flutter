## Why

Osmo Action 4 相机只支持部分模式（拍照、视频、慢动作、静止延时），当前模式选择器显示了该设备不支持的模式（如运动延时、低光视频、人物跟随），导致用户切换到不支持的模式时相机无响应。需要根据设备类型动态过滤显示的模式列表，提升用户体验并避免无效操作。

## What Changes

- 根据连接设备的 device_id 判断设备型号
- Osmo Action 4 (device_id=0xFF33) 只显示：拍照、视频、慢动作、静止延时
- 其他设备（如 Osmo Action 5 Pro, Osmo 360）保留所有模式
- 模式选择器组件动态获取可用模式列表

## Capabilities

### New Capabilities

- `device-mode-filter`: 根据设备类型过滤可用相机模式

### Modified Capabilities

- `mode-scroll-selector`: 需要根据设备类型动态显示模式列表，而非固定显示所有模式

## Impact

- `camera_modes.dart`: 添加设备类型判断和模式过滤逻辑
- `mode_scroll_selector.dart`: 接收过滤后的模式列表
- `ble_service.dart`: 提供 camera device_id 信息
- `session_provider.dart`: 提供设备类型判断方法