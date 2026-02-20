# Contributing to Weakup

感谢你对 Weakup 贡献的兴趣！

## 开发

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/yourusername/weakup.git
cd weakup

# 构建应用
./build.sh

# 运行
open Weakup.app
```

### 项目结构

```
Weakup/
├── Package.swift              # Swift Package 配置
├── build.sh                  # 构建脚本
├── Sources/Weakup/
│   ├── main.swift           # 主程序代码
│   ├── L10n.swift           # 本地化系统
│   ├── en.lproj/           # 英文本地化
│   └── zh-Hans.lproj/      # 简体中文本地化
└── Weakup.app/             # 构建的应用
```

### 代码风格

- 遵循 Swift API 设计指南
- 使用 SwiftUI 构建界面
- 保持函数专注和小巧
- 为复杂逻辑添加注释

### 添加新语言

1. 在 `Sources/Weakup/` 中创建新的 `.lproj` 文件夹
2. 添加包含翻译的 `Localizable.strings`
3. 在 `L10n.swift` 的 `AppLanguage` 枚举中添加语言
4. 在 `AppLanguage.displayName` 中添加显示名称

## 提交更改

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/新功能`)
3. 提交更改 (`git commit -m '添加新功能'`)
4. 推送到分支 (`git push origin feature/新功能`)
5. 打开 Pull Request

## 报告错误

请通过在 GitHub 上提交 issue 来报告错误，并包含：

- macOS 版本
- 重现步骤
- 预期行为
- 实际行为
- 如适用，请附上截图
