## Context

当前相机模式选择器固定显示所有模式（慢动作、视频、静止延时、拍照、运动延时、低光视频、人物跟随），但不同设备支持的模式不同。根据 DJI R SDK 协议文档，设备通过 device_id 区分：
- Osmo Action 4: 0xFF33
- Osmo Action 5 Pro: 0xFF44
- Osmo 360: 0xFF66
- Osmo Action 6: 0xFF55

Osmo Action 4 不支持运动延时、低光视频、人物跟随等模式，需要根据设备类型过滤显示。

## Goals / Non-Goals

**Goals:**
- 根据 device_id 判断设备型号
- 为 Osmo Action 4 提供精简模式列表
- 其他设备保留完整模式列表
- 模式选择器动态接收过滤后的列表

**Non-Goals:**
- 不改变模式切换的协议实现
- 不添加新设备型号的定义（仅使用已有 device_id）
- 不修改相机状态推送解析

## Decisions

1. **设备类型判断位置**: 在 `camera_modes.dart` 中添加设备类型枚举和判断函数
   - 理由：模式定义和设备类型紧密相关，集中管理便于维护
   - 替代方案：在 session_provider 中判断 → 需要额外传递，增加耦合

2. **模式过滤方式**: 提供静态函数 `getSupportedModes(int deviceId)` 返回过滤后的列表
   - 理由：简单直接，无需状态管理
   - 替代方案：Provider 中维护 filteredModes 列表 → 过度设计

## Risks / Trade-offs

- **未识别设备**: device_id 不匹配已知型号时显示全部模式 → 可能显示不支持的模式，但不会崩溃
- **新设备型号**: 需手动添加设备定义 → 可接受的维护成本