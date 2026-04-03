## Why

当前的 GPS 推送使用定时器（2s/5s/10s 间隔），但设备 GPS 更新频率通常为 1Hz。使用定时器推送会导致：
1. 数据不是实时的，有延迟
2. 可能推送过时数据
3. 用户需要手动选择频率，增加操作复杂度

改为实时推送：每次收到 GPS 数据更新时立即推送到相机，确保数据新鲜、实时。

## What Changes

- 移除 GPS 推送频率选择（2s/5s/10s 选项）
- 移除定时器推送逻辑
- 在 GPS 位置流回调中直接触发推送
- 简化 UI，移除频率选择控件
- **BREAKING**: 移除 `pushIntervalSec` 设置

## Capabilities

### New Capabilities

(None)

### Modified Capabilities

- `gps-push`: 移除定时推送，改为实时推送（每次 GPS 更新时推送）

## Impact

- `lib/providers/gps_provider.dart`: 移除定时器逻辑，在位置流回调中直接推送
- `lib/view/gps/gps_settings_view.dart`: 移除频率选择 UI
- `lib/l10n/*.arb`: 移除频率相关本地化字符串（可选保留用于其他用途）