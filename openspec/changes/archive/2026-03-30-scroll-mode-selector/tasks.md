## 1. 数据定义

- [x] 1.1 创建 CameraMode 模式定义常量列表
- [x] 1.2 添加模式图标和名称映射

## 2. 组件实现

- [x] 2.1 创建 ModeScrollSelector 组件骨架
- [x] 2.2 实现 ListWheelScrollView 滚轮视图
- [x] 2.3 添加居中指示器装饰
- [x] 2.4 实现滚动停止检测（NotificationListener + Timer）

## 3. 集成

- [x] 3.1 替换 WorkbenchView 中的 ModeSelector
- [x] 3.2 连接 SessionProvider 的 switchMode 方法
- [x] 3.3 处理当前模式初始化定位

## 4. 测试

- [x] 4.1 测试滚动交互流畅度
- [x] 4.2 测试指令发送时机
- [x] 4.3 测试不同模式切换