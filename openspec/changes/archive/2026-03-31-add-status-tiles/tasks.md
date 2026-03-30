## 1. 数据模型

- [x] 1.1 扩展 CameraStatusModel 添加所有状态字段
- [x] 1.2 添加字段格式化方法（电量、存储、时间等）

## 2. 状态解析

- [x] 2.1 在 BleService 中完整解析 1D02 payload
- [x] 2.2 创建 CameraStatus 数据类
- [x] 2.3 添加 cameraStatusStream 状态流
- [x] 2.4 在 SessionProvider 中集成状态流

## 3. UI 组件

- [x] 3.1 创建 StatusTile 单个磁贴组件
- [x] 3.2 创建 StatusTilesGrid 磁贴网格组件
- [x] 3.3 添加磁贴图标资源

## 4. 集成

- [x] 4.1 在 WorkbenchView 顶部放置状态磁贴
- [x] 4.2 连接状态流实现实时更新
- [x] 4.3 处理连接/断开状态切换

## 5. 测试

- [x] 5.1 真机测试状态解析
- [x] 5.2 验证 UI 显示效果