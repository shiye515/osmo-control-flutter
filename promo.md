# 4天，38次提交，我用 AI + SDD 方法论造了一个 DJI Osmo 第三方遥控器

> 你有没有被 DJI 官方 App 气过？明明就想按个快门，却要等它加载半天；明明就想把手机 GPS 推送给相机，偏偏要买昂贵的配件……直到我写了这个 App。

---

## 故事的起点：一个让人抓狂的 GPS 问题

时间回到 2026 年 3 月。拍摄延时时，我发现 DJI Osmo Action 4 的 GPS 嵌入功能需要依靠外接配件，但手机上明明有精准的 GPS。既然相机可以通过蓝牙连接，为什么不直接把手机 GPS 推送给相机？

想法有了，但问题随之而来：**DJI 从未公开完整的蓝牙控制协议。**

这就是 [osmo-control-flutter](https://github.com/shiye515/osmo-control-flutter) 诞生的背景——一个用 Flutter 编写的开源 App，通过逆向分析 DJI R SDK，实现对 Osmo 相机的完整蓝牙控制。

---

## 上篇：SDD 开发方法论与 4 天极速开发实录

### 什么是 SDD？

在写下第一行代码之前，我做了一个改变整个项目效率的决定：**采用 Spec-Driven Development（规格驱动开发）**。

SDD 的核心理念是：**先精确定义系统「应该做什么」，再让 AI 按规格实现**。它与「让 AI 直接写功能」有本质区别——不是把想法甩给 AI 让它猜，而是先把需求精确成「规格合同」，再由 AI 快速交付。

工作流程如下：

```
你的需求想法
    ↓
[openspec propose] — AI 辅助生成 proposal.md（做什么、为什么）
    ↓
[openspec] — 生成 design.md（怎么做）+ spec.md（精确规格）
    ↓
[openspec apply] — AI 按 spec 实现代码
    ↓
代码审查 & 测试
    ↓
[openspec archive] — 归档变更，形成活文档
```

整个项目使用 [openspec CLI](https://openspec.dev) 作为工作流引擎，GitHub Copilot 作为 AI 实现引擎。每个功能都有对应的 `spec.md`，用精确的 SHALL/MUST 语言描述系统行为，配合具体的 Scenario（场景测试），让 AI 在有边界的约束内高效产出。

### SDD 为什么高效？

**传统方式**："帮我写一个 GPS 推送功能" → AI 猜测意图 → 代码和预期有偏差 → 反复修改

**SDD 方式**：先写规格

```markdown
### Requirement: GPS push command
The system SHALL send GPS data push command (CmdSet=0x00, CmdID=0x17) with payload:
- gps_longitude: 4 bytes (actual value * 10^7)
- gps_latitude: 4 bytes (actual value * 10^7)
- height: 4 bytes (mm)
- speed_to_north: 4 bytes (float, cm/s)
...

#### Scenario: Push GPS coordinates
- WHEN GPS provides latitude=31.2304, longitude=121.4737
- THEN system sends gps_latitude=312304000, gps_longitude=1214737000
```

规格写清楚了，AI 实现的代码第一次就能跑通。**Scenario 既是 AI 的验收测试，也是人工测试的用例。**

---

### Day 0（3月29日）：搭骨架

从零开始，用 Copilot 辅助搭建了 Turborepo monorepo 结构：

- Flutter 移动端（`apps/mobile`）
- Next.js Web 端（`apps/web`）
- Turborepo 统一任务编排

```
2026-03-29  feat: scaffold Turborepo monorepo with Flutter mobile and Next.js web
2026-03-29  fix: upgrade Next.js from 14.2.x to 15.2.9 (fix CVE DoS vulnerability)
```

代码骨架有了，但此时 App 完全无法控制相机——因为协议是错的。

---

### Day 1（3月30日）：发现协议错误，重写核心

这是整个项目最关键的一天。

原有代码使用 DUML 协议（SOF=`0x55`），但真正的 Osmo Action 4 完全不响应。通过对比官方 [Osmo-GPS-Controller-Demo](https://github.com/dji-sdk/Osmo-GPS-Controller-Demo) 源码，我发现：

**DJI Osmo 使用的是完全不同的协议——DJI R SDK（SOF=`0xAA`）！**

不只是协议头不同，连 BLE UUID、CRC 算法、命令集 ID 全都是错的：

| 项目         | 原代码（错误） | 修正后（正确） |
| ------------ | -------------- | -------------- |
| 协议头 SOF   | `0x55`         | `0xAA`         |
| Write UUID   | `FFF6`         | `FFF5`         |
| Notify UUID  | `FFF7`         | `FFF4`         |
| 录制控制命令 | `(0x01, 0x4B)` | `(0x1D, 0x03)` |
| GPS 推送命令 | `(0x04, 0x08)` | `(0x00, 0x17)` |

我用 SDD 方式，**先写 spec 再重写协议层**。这次归档的 openspec proposal 里包含 5 个新 capabilities：

- `dji-r-sdk-protocol`：帧结构、CRC-16/CRC-32 校验、序列号管理
- `connection-auth`：连接鉴权（首次配对 vs. 已配对自动连接）
- `camera-control`：录制/拍照/模式切换/休眠唤醒命令集
- `camera-status-subscription`：相机状态 2Hz 周期推送解析
- `gps-push`：GPS 数据推送协议帧

对 CRC 这种精度极高的算法，spec 的 Scenario 就是验收标准：

```markdown
#### Scenario: CRC-16 computation
- WHEN computing CRC-16 for bytes [0xAA, 0x1B, 0x00, ...]
- THEN result matches DJI R SDK specification
```

当天晚上，相机第一次响应了控制指令。

```
2026-03-30  openspec init
2026-03-30  feat(ble): implement DJI R SDK protocol authentication
2026-03-30  feat(ble): add camera sleep/wake control
```

---

### Day 2（3月31日）：功能爆发——13 次提交

协议层通了，功能开始快速堆叠。这一天产生了 **13 次提交**，上线了几乎所有核心功能：

```
2026-03-31  feat(ui): add camera status tiles display
2026-03-31  feat: add scroll wheel mode selector and fix DJI R SDK commands
2026-03-31  feat: filter camera modes by device type for Osmo Action 4
2026-03-31  feat: add unified record control tile and simplify workbench UI  
2026-03-31  feat: add GPS location service and integrate mode selector as 2x2 tile
2026-03-31  feat: add multi-language support and GPS toggle control
2026-03-31  feat: Refactor device scanning to modal dialog and improve camera status parsing
```

以「设备扫描弹窗」为例，SDD spec 如下：

```markdown
### Requirement: Auto show dialog on startup
系统 SHALL 在应用启动未连接设备时自动弹出扫描弹窗。

#### Scenario: No device connected on startup
- WHEN 应用启动且未连接设备
- THEN 自动弹出扫描弹窗

#### Scenario: Device connected on startup
- WHEN 应用启动且已自动连接设备
- THEN 不弹出扫描弹窗
```

两个 Scenario，定义了完整的分支行为。AI 按照这个 spec 生成代码，一次通过测试。

这一天还实现了一个细节：通过设备 `device_id` 字段自动识别相机型号，并过滤掉不支持的拍摄模式，避免用户发送无效命令：

| `device_id` | 设备型号          |
| ----------- | ----------------- |
| `0xFF33`    | Osmo Action 4     |
| `0xFF44`    | Osmo Action 5 Pro |
| `0xFF55`    | Osmo Action 6     |
| `0xFF66`    | Osmo 360          |

---

### Day 3（4月1日）：打磨与发布

```
2026-04-01  feat: enhance GPS info panel with speed and accuracy data
2026-04-01  feat: show status tiles UI when device is disconnected
2026-04-01  feat: implement correct GPS push command using DJI R SDK protocol
2026-04-01  fix: use DJI R SDK frame writer for GPS push and update README
2026-04-01  docs: add donation section and download links to README
2026-04-01  license: use CC BY-NC-ND 4.0 license
```

修复了 GPS 推送中的时区偏移 bug（DJI 协议要求 UTC+8 时间，简单加 8 小时不够），完善了 GPS 信息面板、添加 App 图标、申请 CC BY-NC-ND 4.0 协议，然后在 GitHub Releases 上发布 Android APK。

**4 天，38 次提交，17 个 openspec 变更归档，12 份 spec 文件——v1.0 完成。**

---

### SDD 方法论总结：我学到的 4 个经验

**1. Spec 是你与 AI 的「合同」**
写好 spec，意味着你对功能已足够清晰。当你写不清楚 spec 时，往往意味着你自己也还没想好——这是很好的强制澄清机制。

**2. Scenario = 测试用例**
每个 `####Scenario` 都是潜在的测试用例。SDD 天然让代码具备可测试性，因为验收标准在写代码前就已确定。

**3. AI 的上限取决于 spec 的质量**
协议层 spec 精确到具体字节值，AI 实现几乎零返工。UI 逻辑 spec 写得模糊，返工次数就多了。

**4. 变更归档是项目的活文档**
17 个归档变更，记录了每个功能的完整决策链路。半年后回来维护，不用猜「当时为什么这么做」。

---

## 下篇：App 功能详细介绍

### 功能一：自动扫描 & 蓝牙连接

打开 App，自动扫描附近的 DJI Osmo 设备。底部弹出扫描弹窗，显示所有可连接设备，点击即可配对连接。

- **首次连接**：鉴权握手（verify_mode=1，随机校验码）
- **再次连接**：自动通过（verify_mode=0）
- **支持设备**：Osmo Action 4 / 5 Pro / 6 / 360

---

### 功能二：相机状态实时监控（磁贴 Dashboard）

连接成功后，工作台顶部以 2×4 磁贴布局展示 8 项实时状态：

| 磁贴       | 示例显示                   |
| ---------- | -------------------------- |
| 🔋 电池     | `85%`                      |
| 💾 存储     | `32GB`                     |
| ⏱ 录制时间 | `00:05:23`                 |
| 📷 相机模式 | `视频`                     |
| 🎬 分辨率   | `4K`                       |
| 🚀 帧率     | `60fps`                    |
| 🎯 增稳模式 | `RS` / `HS` / `RS+` / `HB` |
| 📡 连接状态 | 设备名称                   |

未连接时磁贴显示 `--` 占位符，点击连接磁贴可重新打开扫描弹窗。

---

### 功能三：拍摄控制

#### 开始 / 停止录制

工作台底部录制按钮，实时反映录制状态（红色 = 录制中）。通过 DJI R SDK `(CmdSet=0x1D, CmdID=0x03)` 命令控制：

- `record_ctrl=0`：开始录制
- `record_ctrl=1`：停止录制

#### 切换拍摄模式

滚轮滑动切换，模式选项根据设备型号自动过滤：

- 🎥 视频 / 📸 拍照 / 🌙 夜景
- ⏱ 延时摄影 / 慢动作 / 超广角

#### 相机休眠 & 唤醒

一键休眠省电。唤醒时 App 先广播唤醒数据包（`[10, 0xFF, 'W','K','P', 相机MAC逆序]`），相机自动重连。

---

### 功能四：GPS 数据推送（核心亮点）

**这是让手机替代外接 GPS 配件的功能。**

#### 原理

手机 GPS 数据 → DJI R SDK `(CmdSet=0x00, CmdID=0x17)` 命令 → 相机接收 → 嵌入视频元数据。

在 DJI Mimo App 回放时，可开启仪表盘显示带地图轨迹的位置信息！

#### 推送的 12 个数据字段

| 字段     | 协议精度                 |
| -------- | ------------------------ |
| 经度     | 实际值 × 10⁷（32位整数） |
| 纬度     | 实际值 × 10⁷（32位整数） |
| 高度     | 毫米（mm）               |
| 向北速度 | cm/s（浮点）             |
| 向东速度 | cm/s（浮点）             |
| 垂直速度 | cm/s（浮点）             |
| 水平精度 | mm                       |
| 垂直精度 | mm                       |
| 速度精度 | cm/s                     |
| 卫星数量 | 个（估算）               |
| 年月日   | 4字节编码                |
| 时分秒   | 4字节编码（UTC+8）       |

#### 可配置推送频率

| 频率     | 适用场景               |
| -------- | ---------------------- |
| 每 2 秒  | 运动拍摄，记录详细轨迹 |
| 每 5 秒  | 通用场景               |
| 每 10 秒 | 省电优先的长时延时摄影 |

#### GPS 信息面板

GPS 页面实时显示当前经纬度、速度（含方向分量）、精度估计和定位状态，推送状态一目了然。

---

### 功能五：多语言支持

界面支持中文和英文，自动跟随系统语言切换。所有 UI 文字通过 Flutter `gen-l10n` 的 ARB 文件管理，易于扩展新语言。

---

## 项目信息

| 指标          | 数据                                                         |
| ------------- | ------------------------------------------------------------ |
| 开发周期      | 2026-03-29 ~ 2026-04-01（4天）                               |
| Git 提交      | 38 次                                                        |
| openspec 变更 | 17 个（含迭代）                                              |
| Spec 文件     | 12 份                                                        |
| 支持平台      | iOS & Android                                                |
| 测试机型      | iPhone XS / iPhone 16 Pro Max / Google Pixel / Osmo Action 4 |

### 下载

- **Android APK**：[GitHub Releases](https://github.com/shiye515/osmo-control-flutter/releases)
- **iOS**：正在等待 App Store 审核，敬请期待 🍎

### 开源地址

**https://github.com/shiye515/osmo-control-flutter**

### 技术栈

Flutter · flutter_blue_plus · geolocator · Provider · go_router · Turborepo · openspec CLI · GitHub Copilot

### License

[CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.zh-hans) — 允许分享和个人学习，禁止商业使用和修改分发。

---

> 如果这个项目对你有帮助，欢迎 Star ⭐。  
> 如果你也在探索 SDD + AI 辅助开发工作流，欢迎交流——这可能是效率最高的独立开发方法之一。
