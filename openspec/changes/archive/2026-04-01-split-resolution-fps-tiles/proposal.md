## Why

当前分辨率和帧率合并在一个磁贴中显示，信息密度高不易阅读。同时缺少相机增稳模式（EIS）的显示，用户无法直观了解当前增稳状态。

## What Changes

- 将分辨率+帧率磁贴拆分为两个独立磁贴
- 新增相机增稳模式（EIS）磁贴，显示当前增稳状态（关闭/RS/HS/RS+/HB）

## Capabilities

### New Capabilities

无新增能力

### Modified Capabilities

- `camera-status-tiles`: 修改磁贴布局，拆分分辨率和帧率磁贴，新增 EIS 增稳模式磁贴

## Impact

- `lib/ui/status_tiles_grid.dart` - 修改 `_buildSmallTiles` 方法
- `lib/l10n/app_*.arb` - 可能需要添加 EIS 相关本地化字符串