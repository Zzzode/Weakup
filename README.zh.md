# Weakup

<div align="center">

<img src="Assets/AppIcon.png" width="128" alt="Weakup 应用图标">

[![CI](https://github.com/Zzzode/weakup/actions/workflows/ci.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/ci.yml)
[![Release](https://github.com/Zzzode/weakup/actions/workflows/release.yml/badge.svg)](https://github.com/Zzzode/weakup/actions/workflows/release.yml)
[![codecov](https://codecov.io/gh/Zzzode/weakup/branch/main/graph/badge.svg)](https://codecov.io/gh/Zzzode/weakup)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)
![Swift](https://img.shields.io/badge/Swift-6.2.3-orange)

> **测试范围**：覆盖率徽章仅反映 `WeakupCore` 的单元测试和集成测试。仓库包含 XCUITest 源文件，但当前 Swift Package Manager CI 并未执行 UI 测试。

一个高性能、轻量级的 macOS 防休眠实用工具。

</div>

## 功能特性

- **一键切换** - 单击菜单栏图标即可开启/关闭防休眠
- **菜单栏应用** - 驻留在菜单栏，不占用 Dock
- **定时模式** - 可设置自动关闭计时器（15分钟、30分钟、1小时、2小时、3小时，或自定义时长，最长 24 小时）
- **菜单栏倒计时** - 可在菜单栏图标旁显示剩余时间
- **视觉状态** - 清晰的状态指示（填充/空心的图标），支持多种图标样式
- **全局快捷键** - `Cmd + Ctrl + 0` 随时切换
- **快捷键冲突检测** - 提示常见冲突并建议替代组合
- **原生系统集成** - 使用 macOS IOPMAssertion API 阻止空闲休眠和显示器休眠
- **深色/浅色主题** - 支持系统主题、浅色模式和深色模式
- **声音反馈** - 切换时可选的声音反馈
- **图标自定义** - 从电源、闪电、咖啡、月亮或眼睛图标中选择
- **多语言支持** - 支持 8 种语言实时切换
- **开机自启** - 可选择随登录自动启动
- **通知提醒** - 计时结束时可发送通知
- **新手引导** - 首次启动引导
- **SwiftUI + AppKit** - 现代简洁的代码库

## 支持语言

| 语言 | 显示名称 |
|----------|--------------|
| English | English |
| Chinese (Simplified) | 简体中文 |
| Chinese (Traditional) | 繁體中文 |
| Japanese | 日本語 |
| Korean | 한국어 |
| French | Français |
| German | Deutsch |
| Spanish | Español |

## 安装

### 从源码构建

本地构建是当前**唯一受支持的安装方式**。构建最新稳定版本：

```bash
# 克隆当前稳定版本标签
git clone --branch v1.0.2 --depth 1 https://github.com/Zzzode/weakup.git
cd weakup

# 构建应用
./build.sh

# 运行
open Weakup.app
```

从下一版本开始，GitHub Releases 也会提供从对应发布提交生成的 `Weakup-x.y.z-source.tar.gz` 源码包。

### 预编译版本与 Homebrew 状态

v1.0.2 Release 中的 DMG 和 ZIP 是早期未签名产物，**不支持作为正式安装方式**。Weakup 尚无 Developer ID 签名和 Apple 公证，这些文件可能无法通过 Gatekeeper 和签名校验。Weakup 目前也没有进入 Homebrew 官方 Cask 仓库。

### 系统要求

- macOS 13 或更高版本
- Xcode 工具链，以及 `.swift-version` 指定的 Swift 6.2.3

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
- **通知提醒** - 开启/关闭计时结束通知
- **菜单栏倒计时** - 显示剩余时间
- **图标样式** - 选择你喜欢的菜单栏图标
- **语言** - 在 8 种支持的语言之间切换
- **开机自启** - 登录后自动启动
- **快捷键** - 自定义快捷键并处理冲突提示

## 快捷键

| 快捷键 | 功能 |
|----------|--------|
| `Cmd + Ctrl + 0` | 开启/关闭防休眠 |

## 路线图

### 计划中

- [ ] 定时规则（按时间段自动启停）
- [ ] 菜单栏小组件
- [ ] 与快捷指令集成

当前稳定版本为 **v1.0.2**。已发布变更请参阅 [CHANGELOG.md](CHANGELOG.md)。

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

本项目基于 Apache 2.0 许可证开源 - 详情请参阅 [LICENSE](LICENSE) 文件。

## 致谢

- 基于 [Swift](https://swift.org) 构建
- UI 框架：[SwiftUI](https://developer.apple.com/xcode/swiftui/)
- 防休眠：[IOPMAssertion](https://developer.apple.com/documentation/iokit/iopmassertion)
