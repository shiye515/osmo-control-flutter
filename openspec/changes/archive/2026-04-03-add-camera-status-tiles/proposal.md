## Why

根据协议文档 `docs/protocol_data_segment_CN.md`，相机状态推送（1D02）包含多个字段，但当前应用仅显示了部分信息。剩余拍照张数、循环录像时长、延时摄影参数等信息对用户有实际价值，应该新增磁帖显示。

## What Changes

- **新增用户模式磁帖**: 显示当前自定义模式（通用模式/自定义1-5）
- **新增剩余拍照张数磁帖**: 在拍照模式下显示剩余可拍张数
- **新增循环录像磁帖**: 在视频模式下显示循环录像设置（关闭/5分钟/20分钟/1小时/最大）
- **新增拍照倒计时磁帖**: 在拍照模式下显示倒计时状态
- **新增延时摄影参数磁帖**: 在延时模式下显示拍摄间隔和时长

## Capabilities

### New Capabilities

- `camera-extended-status-tiles`: 扩展相机状态磁帖，显示更多协议字段

### Modified Capabilities

无

## Impact

- **代码文件**:
  - `camera_status_model.dart`: 添加格式化显示方法
  - `status_tiles_grid.dart`: 新增磁帖组件
  - `app_*.arb`: 添加本地化字符串
- **依赖**: 无新增
- **向后兼容**: 完全兼容