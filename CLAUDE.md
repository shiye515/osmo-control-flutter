# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个使用 Turborepo 管理的多端 monorepo 项目，用于控制 DJI Osmo 设备：
- **Web 端**：Next.js 15 + TypeScript + Tailwind CSS（位于 `apps/web`）
- **移动端**：Flutter 蓝牙控制应用（位于 `apps/mobile`）

## 常用命令

### Turborepo（根目录）
```bash
pnpm dev          # 同时启动 web 和 mobile 开发环境
pnpm build        # 构建所有应用
pnpm lint         # lint 所有应用
```

### Web 端（apps/web）
```bash
cd apps/web
pnpm dev          # 启动 Next.js 开发服务器
pnpm build        # 构建 Next.js 应用
pnpm lint         # ESLint 检查
```

### Flutter 移动端（apps/mobile）
```bash
cd apps/mobile
flutter run                    # 运行应用（需连接设备或启动模拟器）
flutter build apk              # 构建 Android APK
flutter build ios              # 构建 iOS（需要 macOS）
flutter analyze                # Dart 分析检查
flutter test                   # 运行测试
flutter pub get                # 安装依赖
flutter gen-l10n               # 生成本地化文件（如有）
```

## 文件命名规范

所有文件必须使用 **snake_case** 命名（例如：`user_profile.dart`、`device_scan_view.dart`）。此规范来自 `agent.md`。

## Flutter 应用架构

`apps/mobile/lib` 目录结构：
```
lib
├── api/           # BLE 服务、协议编解码
├── config/        # 常量、环境配置、主题
├── models/        # 数据模型
├── providers/     # Provider 状态管理
├── routes/        # go_router 路由定义
├── ui/            # 可复用 UI 组件
├── utils/         # 工具函数
└── view/          # 页面视图
```

### 状态管理模式
使用 Provider 包，采用 `ChangeNotifierProxyProvider` 实现依赖链：
- `BleProvider` → `SessionProvider` → `GpsProvider` / `DebugProvider`

查看 `main.dart` 中的 `MultiProvider` 配置。

### BLE 通信
- 使用 `flutter_blue_plus` 与 Osmo 设备通信
- `BleService`（`api/ble_service.dart`）封装扫描、连接、读写
- `ProtocolCodec`（`api/protocol_codec.dart`）实现 DUML 协议编解码

### BLE UUID（见 `app_constants.dart`）
- Service: `0000FFF0-...`
- Write characteristic: `0000FFF6-...`
- Notify characteristic: `0000FFF7-...`

### 路由
使用 `go_router`，入口路由为 `/workbench`，包含 ShellRoute 布局结构。

## Web 端架构

Next.js App Router 结构位于 `apps/web/src/app/`，使用 TypeScript 和 Tailwind CSS。

## 依赖管理

- **Node/Web**：使用 pnpm workspace（见 `pnpm-workspace.yaml`）
- **Flutter**：使用标准 `pubspec.yaml`

## 关键配置文件

- `turbo.json`：Turborepo 任务配置
- `pnpm-workspace.yaml`：pnpm workspace 定义
- `apps/mobile/analysis_options.yaml`：Flutter lint 规则