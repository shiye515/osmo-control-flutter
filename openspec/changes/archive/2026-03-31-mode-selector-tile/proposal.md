## Why

当前相机模式选择器作为独立卡片占据较大空间，且与状态磁贴分离。将模式选择器整合为 2x2 磁贴可以：
- 统一 UI 风格
- 更紧凑地利用屏幕空间
- 保持滚轮选择器的交互体验

## What Changes

- 将模式选择器从独立卡片改为 2x2 磁贴
- 磁贴内部保留 ListWheelScrollView 滚轮交互
- 移除独立的模式选择卡片

## Capabilities

### New Capabilities

无

### Modified Capabilities

- `mode-scroll-selector`: 改为 2x2 磁贴形式，整合到状态磁贴网格中

## Impact

- `status_tiles_grid.dart`: 支持不同大小的磁贴，添加 2x2 模式选择磁贴
- `workbench_view.dart`: 移除独立的模式选择卡片