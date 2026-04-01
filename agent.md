# agent.md

## 项目目标
构建一个使用 Turborepo 管理的多端项目，统一使用 pnpm 作为包管理器。

- Web 端：Next.js + PostgreSQL + Tailwind CSS + shadcn/ui
- 移动端：Flutter

## Monorepo 约束

- 必须使用 Turborepo 组织工作区。
- 必须使用 pnpm（包含 workspace）管理 Node 侧依赖。
- 所有文件名必须使用小写 snake_case（例如：`user_profile.dart`、`order_list.tsx`）。
- 推荐目录结构：

```txt
.
├── apps
│   ├── web                 # Next.js 应用
│   └── mobile              # Flutter 应用
├── packages
│   ├── ui                  # 可选：跨 Web 复用 UI（如需要）
│   ├── config              # 可选：eslint/tsconfig/tailwind 等共享配置
│   └── utils               # 可选：通用工具
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

## Web 端要求（apps/web）

- 框架：Next.js（建议 App Router）
- 样式：Tailwind CSS
- 组件库：shadcn/ui
- 数据库：PostgreSQL
- 基本要求：
  - 使用 TypeScript。
  - 以环境变量管理数据库连接信息。
  - API 与页面分层，避免在页面组件中堆叠数据库逻辑。
  - 组件优先复用，保证命名和目录语义化。

## 移动端要求（apps/mobile）

- 框架：Flutter
- Dart SDK 与 Flutter SDK 使用稳定版，依赖按下列版本约束。

### Flutter dependencies（按需写入 pubspec.yaml）

```yaml
dependencies:
  cupertino_icons: ^1.0.8
  provider: ^6.1.5
  cookie_jar: ^4.0.8
  http: ^1.4.0
  toastification: ^3.0.3
  cached_network_image: ^3.4.1
  go_router: ^16.0.0
  json_annotation: ^4.9.0
  interactive_chart: ^0.3.6
  intl: ^0.20.2
  path_provider: ^2.1.5
  shared_preferences: ^2.5.3
  infinite_scroll_pagination: ^5.1.0
  flutter_svg: ^2.2.0
  countup: ^0.1.4
  qr_flutter: ^4.1.0
  image_picker: ^1.1.2
  path: ^1.9.1
  markdown_widget: ^2.3.2+8
  carousel_slider: ^5.1.1
  url_launcher: ^6.3.2
  logging: ^1.3.0
  photo_view: ^0.15.0
  flutter_image_compress: ^2.4.0
  flutter_blue_plus: ^2.2.1
```

### Flutter lib 目录结构（强约束）

Flutter 项目 `lib` 目录必须采用以下结构：

```txt
lib
├── api
├── config
├── main.dart
├── models
├── providers
├── routes
├── ui
├── utils
└── view
```

目录职责建议：

- api：接口请求、网络封装、拦截与错误转换
- config：环境配置、常量、主题和全局开关
- models：数据模型与序列化定义
- providers：状态管理（Provider）
- routes：路由定义与导航守卫
- ui：可复用 UI 组件
- utils：通用工具函数与扩展
- view：页面级视图

## Agent 执行规范

- 优先生成可直接运行的项目骨架，不做过度设计。
- 修改前先检查是否与既有结构冲突。
- 新增依赖时保持最小集，避免重复引入同类库。
- Web 与 Flutter 两端保持清晰边界，不强行共享不适配逻辑。
- 输出命令、目录和配置时，优先给可复制执行的结果。

## 初始化建议命令

```bash
pnpm dlx create-turbo@latest
```

在生成后按上述目录规范整理 apps/web 与 apps/mobile，并补齐依赖和基础配置。


蓝牙相关的文档请先去 ./docs文件夹中查找
