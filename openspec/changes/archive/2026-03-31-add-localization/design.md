## Context

Flutter 提供内置的国际化支持，通过 `flutter_localizations` 包和 `intl` 包实现。使用 ARB (Application Resource Bundle) 格式存储翻译字符串，通过代码生成创建类型安全的本地化类。

当前应用使用硬编码中文字符串，需要：
1. 配置 l10n.yaml 和 pubspec.yaml
2. 创建 ARB 文件
3. 替换所有硬编码字符串

## Goals / Non-Goals

**Goals:**
- 支持 4 种语言：en (英语), ja (日语), zh (简体中文), zh_Hant (繁体中文)
- 自动跟随系统语言
- 类型安全的字符串访问

**Non-Goals:**
- 不支持动态切换语言（跟随系统）
- 不支持 RTL 语言

## Decisions

### 1. 使用 Flutter 官方 l10n 方案
**决定**: 使用 flutter_localizations + intl + ARB 文件

**理由**: Flutter 官方推荐方案，代码生成类型安全，与 Material/Cupertino 本地化集成良好。

### 2. 语言代码选择
**决定**:
- `en` - 英语
- `ja` - 日语
- `zh` - 简体中文
- `zh_Hant` - 繁体中文（港澳）

**理由**: 遵循标准语言代码规范，`zh_Hant` 覆盖香港和澳门繁体用户。

### 3. 字符串提取策略
**决定**: 手动提取硬编码字符串，按页面/功能模块组织

**理由**: 便于维护，避免遗漏，保持翻译上下文。

## Risks / Trade-offs

**[翻译质量]**: 自动翻译可能不准确
→ Mitigation: 提供翻译对照表，后续可请母语者校对

**[字符串遗漏]**: 部分硬编码字符串可能遗漏
→ Mitigation: 分阶段替换，优先处理用户可见文本