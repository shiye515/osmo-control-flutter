## Why

当前录制和拍照功能使用两个独立按钮，占用空间较多。可以将两者合并为一个智能磁贴，根据相机状态自动决定功能。

## What Changes

- 将"开始录制/停止录制"和"拍照"按钮合并为一个磁贴
- 磁贴根据相机状态自动显示对应功能和图标
- 录制中：显示停止按钮
- 未录制（视频模式）：显示开始录制按钮
- 拍照模式：显示拍照按钮

## Capabilities

### New Capabilities

无

### Modified Capabilities

- `camera-status-tiles`: 添加录制/拍照控制磁贴

## Impact

- `status_tiles_grid.dart`: 添加录制控制磁贴
- `workbench_view.dart`: 移除独立的录制控制卡片