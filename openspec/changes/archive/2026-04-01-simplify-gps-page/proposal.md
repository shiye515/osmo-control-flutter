## Why

GPS 页面功能冗余，用户需要两步操作（启用 GPS + 启用自动推送）才能开始推送位置。简化操作流程，启用自动推送时自动启动 GPS 并开始推送，提升用户体验。

## What Changes

- **移除** GPS 启用开关（简化操作，由自动推送开关统一控制）
- **移除** "立即推送"按钮（自动推送模式下不需要手动推送）
- **修改** 推送频率输入方式：从滑动条改为选择按钮
- **新增** 三个固定频率选项：2秒、5秒、10秒
- **优化** 启用自动推送时自动启动 GPS 并开始推送

## Capabilities

### New Capabilities

无新增能力

### Modified Capabilities

- `gps-push`: 修改 GPS 推送频率选择方式，联动 GPS 启用逻辑

## Impact

- `lib/view/gps/gps_settings_view.dart` - 移除 GPS 开关、立即推送按钮，修改频率选择
- `lib/providers/gps_provider.dart` - 修改自动推送启用逻辑，联动 GPS 启动
- `lib/l10n/app_*.arb` - 可能需要添加频率选项本地化字符串