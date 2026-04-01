## 1. 数据模型扩展

- [x] 1.1 扩展 `GpsPointModel`，添加 speed, speedNorth, speedEast, heading, verticalAccuracy, speedAccuracy 字段
- [x] 1.2 添加计算方法：speedNorth = speed * cos(heading), speedEast = speed * sin(heading)

## 2. LocationService 更新

- [x] 2.1 修改 `_startLocationStream`，提取 Position 的完整信息
- [x] 2.2 更新 GpsProvider 传递新的 GPS 数据字段

## 3. GPS 信息面板 UI

- [x] 3.1 重构 GpsSettingsView 的信息面板为分组布局
- [x] 3.2 添加位置信息组：经度、纬度、高度
- [x] 3.3 添加速度信息组：向东速度、向北速度、总速度
- [x] 3.4 添加精度信息组：水平精度、垂直精度、速度精度
- [x] 3.5 添加卫星数量占位符显示

## 4. 本地化

- [x] 4.1 在 app_*.arb 文件中添加新的本地化字符串
- [x] 4.2 运行 flutter gen-l10n 生成本地化代码