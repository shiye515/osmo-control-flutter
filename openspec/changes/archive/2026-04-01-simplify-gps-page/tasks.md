## 1. 修改 GpsProvider

- [x] 1.1 修改 `setAutoPushEnabled` 方法，启用时自动启动 GPS 采集
- [x] 1.2 修改频率存储，从 Hz 改为秒数间隔（2、5、10）

## 2. 修改 GPS 页面 UI

- [x] 2.1 移除 GPS 启用开关卡片
- [x] 2.2 移除"立即推送"按钮
- [x] 2.3 将频率滑动条改为 SegmentedButton（2秒、5秒、10秒）

## 3. 本地化

- [x] 3.1 添加频率选项本地化字符串

## 4. 测试验证

- [x] 4.1 运行 Flutter analyze 检查代码
- [ ] 4.2 手动测试 GPS 自动推送功能