## Context

当前 `status_tiles_grid.dart` 显示以下相机状态：
- 连接状态、电池、存储、剩余录像时间
- 分辨率、帧率、EIS模式、录制时间
- 温度、相机状态、休眠状态、GPS

根据协议文档，以下字段已解析但未显示：
- `userMode` (偏移27): 用户自定义模式
- `remainPhotoNum` (偏移19-22): 剩余拍照张数
- `loopRecordSecs` (偏移35-36): 循环录像时长
- `photoCountdownMs` (偏移31-34): 拍照倒计时
- `timelapseInterval` (偏移11-12): 延时摄影间隔
- `timelapseDuration` (偏移13-14): 延时录像时长

## Goals / Non-Goals

**Goals:**
- 在适当模式下显示相关参数
- 保持UI简洁，避免信息过载
- 复用现有 StatusTile 组件

**Non-Goals:**
- 不改变现有磁帖布局
- 不添加复杂交互

## Decisions

### 1. 磁帖显示策略

**选择**: 按模式条件显示

**理由**: 不同模式下显示不同参数更合理，避免无意义信息。

| 模式 | 新增显示 |
|------|----------|
| 视频(0x01) | 循环录像时长 |
| 拍照(0x05) | 剩余拍照张数、拍照倒计时 |
| 静止延时(0x02) | 拍摄间隔、录像时长 |
| 运动延时(0x0A) | 拍摄速率 |
| 所有模式 | 用户自定义模式(若非0) |

### 2. 循环录像显示格式

**选择**: 转换为易读格式

```dart
String get loopRecordDisplay {
  if (loopRecordSecs == 0) return 'OFF';
  if (loopRecordSecs == 65535) return 'MAX';
  final minutes = loopRecordSecs ~/ 60;
  if (minutes >= 60) return '${minutes ~/ 60}h';
  return '${minutes}m';
}
```

### 3. 延时摄影间隔显示

**选择**: 转换为秒或自动

```dart
String get timelapseIntervalDisplay {
  if (timelapseInterval == 0) return 'Auto';
  final seconds = timelapseInterval / 10; // 单位0.1秒
  return '${seconds.toStringAsFixed(1)}s';
}
```

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 磁帖数量增加影响布局 | 使用条件显示，仅相关模式展示 |
| 本地化字符串增多 | 复用现有模式，仅新增必要字符串 |