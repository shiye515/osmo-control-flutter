## Context

当前 GPS 推送实现使用 Timer.periodic 定时推送，用户可选择 2s/5s/10s 间隔。但 GPS 数据来自 geolocator 的位置流，更新频率由系统决定（约 1Hz）。定时推送可能导致推送过时数据或不必要的空推送。

## Goals / Non-Goals

**Goals:**
- 每次收到新 GPS 数据时立即推送到相机
- 简化代码，移除定时器逻辑
- 简化 UI，移除频率选择

**Non-Goals:**
- 改变 GPS 获取逻辑（仍使用 geolocator 流）
- 改变 GPS 推送协议

## Decisions

### Decision 1: 在位置流回调中直接推送

**Choice:** 在 `_locationSubscription` 的 listen 回调中，当收到新位置且 autoPushEnabled 时直接调用推送

**Rationale:**
- 数据更新与推送同步，确保数据新鲜
- 无需额外定时器管理
- 减少代码复杂度

### Decision 2: 保留 autoPushEnabled 开关

**Choice:** 保留自动推送开关，但移除频率选择

**Rationale:**
- 用户可能需要控制是否推送 GPS
- 开关控制"是否推送"，不再控制"多久推送"

## Risks / Trade-offs

**推送频率可能较高**
- GPS 更新约 1Hz，意味着每秒推送一次
- 这是可接受的，相机端可以处理
- 如需节流，可在后续添加 debounce

**电量消耗**
- 实时推送可能略增加 BLE 通信和电量消耗
- 但相比录制视频，GPS 推送耗电可忽略