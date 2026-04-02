## Requirements

### Requirement: Promotional article file
系统 SHALL 在项目根目录提供 `promo.md` 推广文章文件。

#### Scenario: Article exists at root
- **WHEN** 访问项目根目录
- **THEN** 存在 `promo.md` 文件

### Requirement: Article structure
文章 SHALL 包含两大主体部分，各占约 50% 篇幅。

#### Scenario: Development process section
- **WHEN** 读者阅读文章第一部分
- **THEN** 看到 SDD 开发过程的时间线叙事，覆盖 2026-03-29 至 2026-04-01

#### Scenario: Feature introduction section
- **WHEN** 读者阅读文章第二部分
- **THEN** 看到 App 所有功能的详细介绍，包括截图替代性文字描述

### Requirement: SDD methodology explanation
文章 SHALL 详细解释 SDD（Spec-Driven Development）开发方法论。

#### Scenario: SDD workflow explanation
- **WHEN** 读者阅读 SDD 介绍段落
- **THEN** 理解"先写 spec，AI 辅助实现"的核心流程

#### Scenario: Concrete SDD examples
- **WHEN** 读者阅读具体案例
- **THEN** 看到至少 3 个 spec → 实现的具体例子（如协议认证、GPS 推送、相机状态磁贴）
