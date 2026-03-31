## Context

应用需要获取设备 GPS 位置并推送给 DJI Osmo 相机。使用 geolocator 包实现跨平台定位，需要配置各平台权限。

## Goals / Non-Goals

**Goals:**
- 集成 geolocator 包
- 配置 Android/iOS 权限
- 封装定位服务
- 提供位置流供 GPS 推送使用

**Non-Goals:**
- 后台定位（仅需前台定位）
- 地理编码功能

## Decisions

1. **权限策略**: 仅请求 `whenInUse` 权限，不请求后台定位
   - 理由：相机控制应用不需要后台定位，减少权限敏感度

2. **精度设置**: 使用高精度定位
   - 理由：GPS 推送需要准确坐标

3. **服务封装**: 创建 LocationService 单例
   - 理由：统一管理定位逻辑，方便 Provider 使用

## Risks / Trade-offs

- 用户可能拒绝权限 → 需要友好的提示和引导
- 定位可能失败 → 需要错误处理和重试机制