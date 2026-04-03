## Context

当前应用使用 ShellRoute + BottomNavigationBar 结构，包含3个导航入口：
- 遥控器（WorkbenchView）
- 调试台（DebugConsoleView）
- 设置（SettingsView）

首页磁帖网格当前有4列，第一行包含：连接状态、电量、存储、剩余时间。用户希望简化导航结构，将设置入口集成到磁帖中。

## Goals / Non-Goals

**Goals:**
- 移除底部导航栏，简化界面
- 在磁帖第一行第4个位置添加设置入口
- 将调试台入口移至设置页面
- 使用 AboutListTile 展示应用关于信息

**Non-Goals:**
- 不修改磁帖网格的其他布局
- 不修改调试台页面的功能

## Decisions

1. **设置磁帖位置**
   - 第一行前3个磁帖保持不变（连接状态、电量、存储）
   - 第4个磁帖改为设置入口
   - 理由：第一行是高频操作区域，设置作为常用入口适合放在此处

2. **路由结构调整**
   - 移除 ShellRoute，改用简单的单页面路由
   - WorkbenchView 作为主页直接显示
   - SettingsView 和 DebugConsoleView 作为子页面通过 `context.push` 导航
   - 理由：简化导航结构，减少不必要的嵌套

3. **AboutListTile 实现**
   - 使用 Flutter 内置的 `AboutListTile` 组件
   - 配置 `applicationName`、`applicationVersion`、`applicationLegalese`
   - 理由：遵循 Material Design 规范，自动处理版权信息展示

## Risks / Trade-offs

- **Risk**: 用户可能需要适应新的导航方式
  → **Mitigation**: 设置磁帖放在显眼位置，操作路径更短（减少一次点击）

- **Risk**: 调试台入口隐藏到设置页面，可能不易发现
  → **Mitigation**: 调试台主要面向开发者用户，放在设置页面更符合预期