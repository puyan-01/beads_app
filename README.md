# beads_app

`beads_app` 是一个基于 Flutter 的跨平台应用项目，当前为基础模板版本（计数器示例）。

## 项目简介

- 技术栈：Flutter + Dart
- 支持平台：Android、iOS、Web、Windows、macOS、Linux
- 当前状态：可作为新功能开发的起始工程

## 环境要求

开始前请确保本机已安装：

- Flutter SDK（建议使用稳定版）
- Dart SDK（通常随 Flutter 一起安装）
- 对应平台的构建工具（如 Android Studio / Xcode / Chrome 等）

可通过以下命令检查环境：

```bash
flutter doctor
```

## 快速开始

1. 获取依赖

```bash
flutter pub get
```

2. 启动应用（默认设备）

```bash
flutter run
```

3. 指定平台运行（示例）

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## 常用命令

```bash
# 代码静态检查
flutter analyze

# 运行测试
flutter test

# 构建发布包（示例）
flutter build apk
flutter build web
```

## 目录结构

```text
beads_app/
├─ lib/            # 核心业务代码（入口 main.dart）
├─ test/           # 测试代码
├─ android/        # Android 平台工程
├─ ios/            # iOS 平台工程
├─ web/            # Web 平台资源
├─ windows/        # Windows 平台工程
├─ macos/          # macOS 平台工程
├─ linux/          # Linux 平台工程
├─ pubspec.yaml    # 依赖与项目配置
└─ README.md
```

## 开发建议

- 新增功能优先放在 `lib/` 下按模块拆分目录。
- 提交代码前建议执行 `flutter analyze` 与 `flutter test`。
- 涉及多端适配时，优先在目标平台分别验证关键流程。

## 参考文档

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter 中文社区](https://flutter.cn/)
