## Why

当前应用连接相机后，用户无法直观看到相机的详细状态信息（电量、存储、录制时间、分辨率等）。需要在页面顶部以磁贴形式展示这些状态，让用户一目了然地了解相机当前状态。

## What Changes

- 解析相机状态推送 (0x1D, 0x02) 的所有字段
- 创建状态磁贴 UI 组件，每行 4 个正方形磁贴
- 将磁贴放置在页面最上部
- 实时更新状态显示

### 状态字段列表

| 字段 | 说明 | 显示方式 |
|------|------|----------|
| camera_bat_percentage | 电池电量 | 百分比 + 图标 |
| remain_capacity | SD卡剩余容量 | GB 单位 |
| remain_photo_num | 剩余拍照张数 | 数字 |
| remain_time | 剩余录像时间 | 时:分:秒 |
| camera_mode | 相机模式 | 图标 + 文字 |
| camera_status | 相机状态 | 图标 + 文字 |
| video_resolution | 分辨率 | 数字 (如 4K) |
| fps_idx | 帧率 | fps |
| record_time | 录制时间 | 时:分:秒 |
| power_mode | 电源模式 | 图标 |
| temp_over | 温度状态 | 图标 + 颜色 |

## Capabilities

### New Capabilities

- `camera-status-tiles`: 相机状态磁贴展示组件

### Modified Capabilities

- `camera-status-subscription`: 扩展状态解析，解析完整的状态推送字段

## Impact

- **BLE 服务**: 解析完整的状态推送 payload
- **数据模型**: 创建完整的 CameraStatus 模型
- **UI**: 新增状态磁贴组件，放置在 workbench_view.dart 顶部