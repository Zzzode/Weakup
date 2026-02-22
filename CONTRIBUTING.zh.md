# 贡献指南

感谢你对 Weakup 贡献的兴趣！本文档提供了参与项目贡献的指南。

## 目录

- [行为准则](#行为准则)
- [快速开始](#快速开始)
- [开发设置](#开发设置)
- [项目结构](#项目结构)
- [进行更改](#进行更改)
- [代码风格](#代码风格)
- [测试](#测试)
- [提交更改](#提交更改)
- [报告错误](#报告错误)
- [功能请求](#功能请求)

## 行为准则

- 保持尊重和包容
- 欢迎新人并帮助他们上手
- 专注于建设性的反馈
- 假设善意

## 快速开始

### 前置要求

- macOS 13.0 (Ventura) 或更高版本
- Xcode 命令行工具 (`xcode-select --install`)
- Swift 6.0+
- Git

### 快速上手

```bash
# 克隆仓库
git clone https://github.com/Zzzode/weakup.git
cd weakup

# 构建应用
./build.sh

# 运行
open Weakup.app
```

## 开发设置

有关详细的开发说明，请参阅 [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)。

### 构建

```bash
# 完整构建（包含应用包）
./build.sh

# 快速构建（无应用包）
swift build -c release
```

### 运行

```bash
# 运行应用包
open Weakup.app

# 直接运行二进制文件（用于快速测试）
.build/release/weakup
```

## 项目结构

```
Weakup/
├── Package.swift              # Swift Package 配置
├── build.sh                   # 构建脚本
├── Sources/Weakup/
│   ├── main.swift             # 主程序代码
│   │   ├── WeakupApp          # 入口点
│   │   ├── AppDelegate        # 系统集成
│   │   ├── CaffeineViewModel  # 业务逻辑
│   │   └── SettingsView       # SwiftUI 界面
│   ├── L10n.swift             # 本地化系统
│   ├── en.lproj/              # 英文本地化
│   │   └── Localizable.strings
│   └── zh-Hans.lproj/         # 中文本地化
│       └── Localizable.strings
├── docs/                      # 文档
│   ├── ARCHITECTURE.md        # 系统架构
│   ├── DEVELOPMENT.md         # 开发指南
│   ├── TESTING.md             # 测试指南
│   ├── TRANSLATIONS.md        # 翻译指南
│   └── PRIVACY.md             # 隐私政策
└── Weakup.app/                # 构建的应用程序
```

## 进行更改

### 分支命名

- `feature/description` - 新功能
- `fix/description` - 错误修复
- `docs/description` - 文档
- `refactor/description` - 代码重构
- `translation/language-code` - 新翻译

### 提交信息

编写清晰、简洁的提交信息：

```
Add timer expiry notification

- Show macOS notification when timer reaches zero
- Add notification permission request
- Update localization strings
```

## 代码风格

### Swift 指南

- 遵循 [Swift API 设计指南](https://swift.org/documentation/api-design-guidelines/)
- 使用 SwiftUI 构建 UI 组件
- 保持函数专注且简短（30 行以内）
- 使用有意义的变量和函数名
- 仅为复杂逻辑添加注释

### 格式化

```swift
// 推荐
func toggleCaffeine() {
    viewModel.toggle()
    updateStatusIcon()
}

// 避免
func toggleCaffeine(){viewModel.toggle();updateStatusIcon()}
```

### SwiftUI 最佳实践

- 将可重用的视图提取为单独的结构体
- 对拥有的对象使用 `@StateObject`，对传递的对象使用 `@ObservedObject`
- 保持视图主体简单易读

## 测试

有关详细的测试指南，请参阅 [docs/TESTING.md](docs/TESTING.md)。

### 手动测试清单

在提交 PR 之前，请验证：

- [ ] 防休眠切换正常
- [ ] 定时模式按预期工作
- [ ] 键盘快捷键 (Cmd+Ctrl+0) 功能正常
- [ ] 语言切换正常
- [ ] 应用完全退出
- [ ] 无内存泄漏或崩溃

### 验证电源断言

```bash
# 检查断言是否正确创建/释放
pmset -g assertions
```

## 提交更改

### Pull Request 流程

1. Fork 仓库
2. 创建功能分支：

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. 进行更改
4. 彻底测试
5. 使用清晰的信息提交：

   ```bash
   git commit -m 'Add amazing feature'
   ```

6. 推送到你的 Fork：

   ```bash
   git push origin feature/amazing-feature
   ```

7. 打开 Pull Request

### PR 清单

- [ ] 代码遵循项目风格指南
- [ ] 更改已手动测试
- [ ] 如有需要，已更新文档
- [ ] 为新 UI 文本添加了本地化字符串
- [ ] 无破坏性更改（或已明确记录）

### 审查流程

- PR 需要至少一次批准
- 及时处理审查反馈
- 保持 PR 专注且大小合理

## 报告错误

在 GitHub 上提交 issue 并包含：

- **macOS 版本**（例如 macOS 14.2）
- **Weakup 版本**（如果已知）
- **重现步骤**
- **预期行为**
- **实际行为**
- **截图**（如适用）
- **控制台日志**（如有）

### 获取控制台日志

```bash
# 运行应用并捕获输出
./build/release/weakup 2>&1 | tee weakup.log
```

## 功能请求

我们欢迎功能建议！提交 issue 并包含：

- 清晰的功能描述
- 用例 / 为什么它有用
- 任何实现思路（可选）

### 路线图功能

查看 README 了解计划中的功能。特别欢迎针对路线图项目的 PR。

## 添加新语言

查看 [docs/TRANSLATIONS.md](docs/TRANSLATIONS.md) 获取完整的翻译指南。

快速步骤：

1. 创建 `Sources/Weakup/XX.lproj/Localizable.strings`
2. 在 `L10n.swift` 的 `AppLanguage` 枚举中添加语言
3. 更新 `build.sh` 以复制新的本地化文件
4. 彻底测试

## 有问题？

- 提交 issue 提问
- 先检查现有的 issue 和文档
- 请耐心等待 - 维护者是志愿者

## 许可证

通过贡献，你同意你的贡献将根据 Apache 2.0 许可证授权。

---

感谢你为 Weakup 做出贡献！
