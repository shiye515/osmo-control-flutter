# osmo-control-flutter

一个用于控制 DJI Osmo 设备的跨平台移动应用，支持 iOS 和 Android。

> 🙏 如果这个项目对你有帮助，请考虑请作者喝杯咖啡，您的支持是我继续维护的动力...
>
> <img src="docs/qr.JPG" width="200" alt="打赏二维码">

## 下载

- **Android**: [前往 Releases 下载 APK](https://github.com/shiye515/osmo-control-flutter/releases)
- **iOS**: 🍎 正在等待 App Store 审核，敬请期待...

## 功能特性

### 设备状态显示
- 电量百分比
- 存储容量
- 当前分辨率
- 增稳模式（RS/HS/RS+/HB）
- 相机模式（视频/拍照/延时摄影等）

### 拍摄控制
- 切换拍摄模式
- 开始/结束录制
- 拍照快门控制

### GPS 数据推送
- 推送位置信息到相机（经纬度、高度、速度分量）
- 支持多种推送频率（2s/5s/10s）
- 开启 GPS 推送后进行录制，可在 DJI Mimo App 内编辑视频时开启仪表盘显示

## 测试设备

| 设备类型 | 型号                         |
| -------- | ---------------------------- |
| iOS      | iPhone XS, iPhone 16 Pro Max |
| Android  | Google Pixel X Style         |
| 相机     | DJI Osmo Action 4            |


## 技术栈

- **Flutter** - 跨平台移动应用框架
- **flutter_blue_plus** - BLE 蓝牙通信
- **geolocator** - GPS 位置服务
- **Provider** - 状态管理
- **go_router** - 路由导航

## 项目结构

```
apps/mobile/
├── lib/
│   ├── api/           # BLE 服务、协议编解码
│   ├── config/        # 常量、环境配置、主题
│   ├── models/        # 数据模型
│   ├── providers/     # Provider 状态管理
│   ├── routes/        # go_router 路由定义
│   ├── ui/            # 可复用 UI 组件
│   ├── utils/         # 工具函数
│   └── view/          # 页面视图
└── pubspec.yaml
```

## 开发

```bash
# 安装依赖
cd apps/mobile
flutter pub get

# 运行应用
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios
```

## 协议参考

本应用使用 DJI R SDK 协议与 Osmo 设备通信，协议文档参考[Osmo-GPS-Controller-Demo](https://github.com/dji-sdk/Osmo-GPS-Controller-Demo)

## License

本作品采用 [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.zh-hans) 协议授权。

允许：分享、个人学习使用
禁止：商业使用、修改后分发