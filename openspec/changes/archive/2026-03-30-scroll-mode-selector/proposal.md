## Why

当前模式切换使用简单的按钮列表，交互体验不够直观。使用滚轮选择器可以让用户更自然地浏览和选择模式，停止滚动后自动发送切换指令，减少误操作。

## What Changes

- 创建滚轮式模式选择器组件（类似 iOS 时间选择器）
- 支持上下滚动选择不同相机模式
- 滚动停止后自动发送切换指令
- 显示当前模式和可选模式列表

## Capabilities

### New Capabilities

- `mode-scroll-selector`: 滚轮式相机模式选择器组件

### Modified Capabilities

- `camera-control`: 模式切换交互从按钮改为滚轮选择器

## Impact

- 新增 `ModeScrollSelector` 组件
- 替换现有的 `ModeSelector` 组件
- 使用 `ListWheelScrollView` 实现滚轮效果
- 添加滚动停止检测和指令发送逻辑