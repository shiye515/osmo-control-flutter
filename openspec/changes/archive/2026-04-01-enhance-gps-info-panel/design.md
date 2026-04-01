## Context

当前 GPS 实现使用 `geolocator` 包获取设备位置，但只使用了基本的经纬度和高度信息。`geolocator` 的 `Position` 对象包含更多信息，部分用户需求的数据需要额外处理或使用平台特定 API。

### 数据来源分析

| 数据 | geolocator Position | 备注 |
|------|---------------------|------|
| 经度 | `longitude` ✓ | 直接获取 |
| 纬度 | `latitude` ✓ | 直接获取 |
| 高度 | `altitude` ✓ | 直接获取 |
| 水平精度 | `accuracy` ✓ | 直接获取 |
| 垂直精度 | `altitudeAccuracy` ✓ | Android/iOS 均支持 |
| 速度 | `speed` ✓ | m/s |
| 速度精度 | `speedAccuracy` ✓ | m/s |
| 航向 | `heading` ✓ | 度 |
| 卫星数量 | ❌ | 需要平台特定实现 |

### 速度分量计算

- **向东速度**: `speed * sin(heading)`
- **向北速度**: `speed * cos(heading)`
- **垂直速度**: 需要连续两次高度采样计算，或使用气压计

### 卫星数量

iOS 和 Android 均不通过标准位置 API 暴露卫星数量。需要：
- Android: 使用 `LocationManager.getGnssStatus()`
- iOS: 使用 `CLLocationManager` 的 `authorizationStatus` 和私有 API（受限）

考虑到跨平台兼容性，卫星数量暂时显示为 "--" 或 "N/A"，后续可通过 MethodChannel 实现平台特定功能。

## Goals / Non-Goals

**Goals:**
- 扩展 GPS 数据模型，包含速度分量和精度信息
- 重新设计 GPS 信息面板，清晰展示所有 GPS 数据
- 使用 geolocator 提供的所有可用信息

**Non-Goals:**
- 不实现卫星数量的实时获取（需要平台特定代码，留作后续增强）
- 不修改 GPS 推送协议（仅展示，不影响设备通信）
- 不添加数据导出功能

## Decisions

### 1. 速度分量计算方式

**决定**: 使用 `speed` 和 `heading` 计算东向和北向速度分量。

**理由**:
- geolocator 提供 `speed` (m/s) 和 `heading` (度)
- 公式：`east = speed * sin(heading_rad)`, `north = speed * cos(heading_rad)`
- 无需额外传感器

### 2. 垂直速度处理

**决定**: 暂不实现垂直速度，显示为 "--"。

**理由**:
- 需要连续两次高度采样计算，精度不稳定
- 气压计数据在标准 API 中不可用
- 留作后续增强

### 3. 卫星数量处理

**决定**: 暂不实现卫星数量，显示为 "--"。

**理由**:
- geolocator 不提供此信息
- 需要平台特定 MethodChannel 实现
- 复杂度高，收益有限

### 4. UI 布局设计

**决定**: 使用分组卡片布局，分为"位置信息"和"速度与精度"两组。

**理由**:
- 信息层次清晰
- 便于用户快速定位所需数据
- 与现有设计风格一致

## Risks / Trade-offs

[Risk] 部分 Android 设备可能不报告 `altitudeAccuracy` 和 `speedAccuracy` → Mitigation: 使用 null safety，缺失时显示 "--"

[Risk] 速度分量计算基于航向，航向精度影响结果 → Mitigation: 显示速度精度，让用户了解数据可信度

[Risk] UI 信息过多可能影响可读性 → Mitigation: 使用分组和合适的字体大小