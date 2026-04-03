## 1. 本地化字符串

- [x] 1.1 在 `app_zh.arb` 中添加 `disconnect` 字符串
- [x] 1.2 在 `app_en.arb` 中添加 `disconnect` 英文翻译

## 2. 移除自动连接横幅

- [x] 2.1 删除 `_AutoConnectBanner` 组件
- [x] 2.2 移除弹层中的 `_AutoConnectBanner` 调用

## 3. 新增已连接设备区域

- [x] 3.1 创建 `_ConnectedDeviceTile` 组件，显示已连接设备信息和断开按钮
- [x] 3.2 在弹层布局中添加已连接设备区域（标题栏下方）

## 4. 测试验证

- [x] 4.1 运行 `flutter analyze` 确保无静态分析错误
- [ ] 4.2 手动测试：连接设备后打开弹层，验证已连接设备显示和断开功能