## 1. CameraStatusModel 扩展

- [x] 1.1 在 `CameraStatusModel` 中添加 `userModeDisplay` 格式化方法
- [x] 1.2 在 `CameraStatusModel` 中添加 `remainPhotoDisplay` 格式化方法
- [x] 1.3 在 `CameraStatusModel` 中添加 `loopRecordDisplay` 格式化方法
- [x] 1.4 在 `CameraStatusModel` 中添加 `photoCountdownDisplay` 格式化方法
- [x] 1.5 在 `CameraStatusModel` 中添加 `timelapseIntervalDisplay` 格式化方法

## 2. 本地化字符串

- [x] 2.1 在 `app_zh.arb` 中添加新字符串（userMode, remainingPhotos, loopRecording, photoCountdown, timelapseInterval）
- [x] 2.2 在 `app_en.arb` 中添加对应英文翻译

## 3. UI 磁帖实现

- [x] 3.1 在 `status_tiles_grid.dart` 中添加用户模式磁帖（条件显示：userMode != 0）
- [x] 3.2 在 `status_tiles_grid.dart` 中添加剩余拍照张数磁帖（条件显示：拍照模式）
- [x] 3.3 在 `status_tiles_grid.dart` 中添加循环录像磁帖（条件显示：视频模式且 loopRecordSecs > 0）
- [x] 3.4 在 `status_tiles_grid.dart` 中添加延时摄影参数磁帖（条件显示：延时模式）

## 4. 测试验证

- [x] 4.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 4.2 手动测试：切换相机模式验证相应磁帖显示