## Why

应用需要支持多语言以服务全球用户。当前应用仅支持中文，需要添加国际化支持以扩展用户群体。

## What Changes

- 集成 Flutter 国际化框架（flutter_localizations + intl）
- 添加 4 种语言支持：英语、日语、简体中文、港澳繁体
- 提取应用中所有硬编码的中文字符串到 ARB 资源文件
- 应用启动时自动检测系统语言并切换

## Capabilities

### New Capabilities

- `app-localization`: 应用多语言国际化支持能力

### Modified Capabilities

无（新功能）

## Impact

- `pubspec.yaml`: 添加 flutter_localizations 和 intl 依赖
- `lib/l10n/`: 新建本地化资源目录和生成的代码
- `lib/main.dart`: 配置 MaterialApp 的 localizationsDelegates
- 所有 UI 文件中硬编码的字符串需要替换为 AppLocalizations 调用