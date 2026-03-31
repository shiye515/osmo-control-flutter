## 1. StatusTilesGrid 主体修改

- [x] 1.1 移除 `StatusTilesGrid.build()` 中 `!isConnected` 返回空 Widget 的逻辑
- [x] 1.2 修改 `_buildSmallTiles()` 方法，根据 `isConnected` 状态决定显示占位符或实际数据

## 2. 连接磁贴修改

- [x] 2.1 修改 `_ConnectionTile` 组件，添加 `isConnected` 参数
- [x] 2.2 未连接时显示"未连接"状态和图标
- [x] 2.3 保持点击可弹出扫描弹窗功能

## 3. 录制控制磁贴禁用

- [x] 3.1 修改 `_RecordControlTile`，添加 `enabled` 参数
- [x] 3.2 未连接时禁用点击交互，显示灰色外观

## 4. 模式选择器禁用

- [x] 4.1 修改 `_ModeSelectorTile`，添加 `enabled` 参数
- [x] 4.2 未连接时禁用滚动交互，固定显示默认模式

## 5. 添加本地化字符串

- [x] 5.1 在 `app_zh_Hant.arb` 中添加 "disconnected" 字符串
- [x] 5.2 在其他语言 ARB 文件中同步添加