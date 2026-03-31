## 1. 添加 EIS 显示方法

参考文档 https://github.com/dji-sdk/Osmo-GPS-Controller-Demo/blob/main/docs/protocol_data_segment_CN.md

- [x] 1.1 在 CameraStatusModel 中添加 `eisModeDisplay` getter

## 2. 修改磁贴布局

- [x] 2.1 将分辨率+帧率磁贴拆分为两个独立磁贴
- [x] 2.2 新增 EIS 增稳模式磁贴

## 3. 本地化

- [x] 3.1 添加 EIS 模式本地化字符串（OFF/RS/HS/RS+/HB）

## 4. 测试验证

- [x] 4.1 运行 Flutter analyze 检查代码
- [ ] 4.2 手动测试磁贴显示