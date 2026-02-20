# Weakup

<div align="center">

[![CI](https://github.com/Zzzode/weakup/actions/workflows/ci.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/ci.yml)
[![Release](https://github.com/Zzzode/weakup/actions/workflows/release.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/release.yml)
[![codecov](https://codecov.io/gh/Zzzode/weakup/branch/main/graph/badge.svg)](https://codecov.io/gh/Zzzode/weakup)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)

一个高性能、轻量级的 macOS 防休眠实用工具。

</div>

## 功能特性

- **一键切换** - 单击菜单栏图标即可开启/关闭防休眠
- **菜单栏应用** - 驻留在菜单栏，不占用 Dock
- **定时模式** - 可设置自动关闭计时器（15分钟、30分钟、1小时、2小时、3小时，或自定义时长，最长 24 小时）
- **视觉状态** - 清晰的状态指示（填充/空心的图标），支持多种图标样式
- **全局快捷键** - `Cmd + Ctrl + 0` 随时切换
- **原生性能** - 使用 IOPMAssertion API，零开销
- **深色/浅色主题** - 支持系统主题、浅色模式和深色模式
- **声音反馈** - 切换时可选的声音反馈
- **图标自定义** - 从电源、闪电、咖啡、月亮或眼睛图标中选择
- **多语言支持** - 支持 8 种语言实时切换
- **SwiftUI + AppKit** - 现代简洁的代码库

## 支持语言

| 语言 | 显示名称 |
|----------|--------------|
| English | English |
| Chinese (Simplified) | 简体中文 |
| Chinese (Traditional) | 繁體中文 |
| Japanese | 日本語 |
| Korean | 한국어 |
| French | Francais |
| German | Deutsch |
| Spanish | Espanol |

## 截图

| 设置 (English) | 设置 (中文) |
|--------------------|-------------------|
| ![English](screenshots/english.png) | ![Chinese](screenshots/chinese.png) |

## 安装

### Homebrew (推荐)

```bash
brew install --cask weakup
```

### 下载发布版

从 [GitHub Releases](https://github.com/Zzzode/weakup/releases) 下载最新版本：

1. 下载 `Weakup-x.x.x.dmg`
2. 打开 DMG 并将 Weakup 拖入应用程序文件夹
3. 从应用程序文件夹启动

### 源码编译

```bash
# 克隆仓库
git clone https://github.com/Zzzode/weakup.git
cd weakup

# 构建应用
./build.sh

# 运行
open Weakup.app

# 或者将 Weakup.app 拖入你的应用程序文件夹
```

### 系统要求

- macOS 13.0 或更高版本
- Xcode 命令行工具

## 使用方法

1. 点击菜单栏图标切换防休眠状态
2. 右键单击或选择「设置」访问选项
3. 使用 `Cmd + Ctrl + 0` 快捷键随时切换
4. 在设置面板中即时切换语言

### 设置选项

- **定时模式** - 启用设定时长后自动关闭
- **时长** - 选择预设时间或设置自定义时长（最长 24 小时）
- **主题** - 系统、浅色或深色
- **声音反馈** - 开启/关闭音频反馈
- **图标样式** - 选择你喜欢的菜单栏图标
- **语言** - 在 8 种支持的语言之间切换

## 快捷键

| 快捷键 | 功能 |
|----------|--------|
| `Cmd + Ctrl + 0` | 开启/关闭防休眠 |

## 路线图

### 已完成

- [x] 深色/浅色主题支持
- [x] 自定义定时时长
- [x] 切换动作的声音反馈
- [x] 菜单栏图标自定义
- [x] 多语言支持（8 种语言）
- [x] MVVM 架构重构
- [x] CI/CD 流水线
- [x] SwiftLint 和 SwiftFormat 集成

### 计划中

- [ ] 登录时启动偏好设置
- [ ] 活动历史记录和统计
- [ ] 键盘快捷键冲突检测

### 最近完成

- [ ] 计时器结束时的 macOS 通知
- [ ] 在菜单栏显示倒计时
- [ ] Homebrew Cask 配方

## 文档

- [架构](docs/ARCHITECTURE.md) - 系统架构概览
- [开发](docs/DEVELOPMENT.md) - 设置和开发工作流
- [测试](docs/TESTING.md) - 测试指南
- [翻译](docs/TRANSLATIONS.md) - 添加新语言指南
- [代码签名](docs/CODE_SIGNING.md) - 代码签名和公证指南
- [Homebrew](docs/HOMEBREW.md) - Homebrew 安装指南
- [隐私](docs/PRIVACY.md) - 隐私政策

## 贡献

欢迎贡献！详情请参阅 [CONTRIBUTING.zh.md](CONTRIBUTING.zh.md)。

[English](CONTRIBUTING.md) | [中文](CONTRIBUTING.zh.md)

## 许可证

本项目基于 MIT 许可证开源 - 详情请参阅 [LICENSE](LICENSE) 文件。

## 致谢

- 基于 [Swift](https://swift.org) 构建
- UI 框架：[SwiftUI](https://developer.apple.com/xcode/swiftui/)
- 防休眠：[IOPMAssertion](https://developer.apple.com/documentation/iokit/iopmassertion)
