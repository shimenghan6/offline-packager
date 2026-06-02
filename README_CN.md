# Claude Code 离线安装包

## 你拿到的是什么

这是一个 Claude Code 一键安装包。双击 `install-offline.bat`，按提示操作即可。

| 套餐 | 价格 | 包含 Skill | 微信远程 |
|------|:---:|------|:---:|
| 基础版 | ¥88 | 无 | - |
| 进阶版 | ¥168 | browser-control, github-research, sound-notifier, github-publisher | - |
| 尊享版 | ¥298 | 同上 4 个 | ✓ 支持 |

## 安装步骤

1. 解压 ZIP 到任意目录
2. 双击 `install-offline.bat`
3. 按提示操作：确认 VS Code → 确认 Node.js → 确认 Claude Code → 输入 DeepSeek API Key → Skill 自动安装
4. 完成后打开终端，输入 `claude` 即可使用

## 需要什么

| 需求 | 说明 |
|------|------|
| Windows 10/11 | 仅支持 Windows |
| 网络 | 下载 Claude Code 和 npm 包时需要 |
| DeepSeek API Key | 免费注册：platform.deepseek.com |
| 约 10 分钟 | 首次安装时间 |

## 安装后怎么用

打开终端（PowerShell 或 CMD），输入 `claude`，然后说：

| 想做什么 | 对 Claude 说 |
|---------|------------|
| 打开浏览器搜索 | "open browser and search for xxx" |
| 搜 GitHub 项目 | "search GitHub for xxx tool" |
| 发布项目到 GitHub | "publish this project to GitHub" |
| 打开声音提醒 | "turn on sound notifications" |

## 常见问题

**Q: 提示"Node.js not found"？**
A: Node.js 安装失败不影响 Skill 使用。但 Claude Code 需要 Node.js，请手动从 https://nodejs.org 下载安装后重新运行此脚本。

**Q: 没有 DeepSeek API Key？**
A: 去 https://platform.deepseek.com 免费注册，创建 API Key，重新运行脚本输入即可。或手动编辑 `%USERPROFILE%\.claude\settings.json`。

**Q: 安装后输入 claude 没反应？**
A: 重启终端，或检查 npm 全局路径是否在 PATH 环境变量中。

**Q: VS Code 装不上？**
A: 手动从 https://code.visualstudio.com 下载安装，然后重新运行脚本，它会自动安装 Claude Code 扩展。

**Q: 不想要某个 Skill？**
A: 删除 `%USERPROFILE%\.claude\skills\<skill名>\` 目录即可。

## 文件说明

```
你的解压目录/
├── install-offline.bat      ← 双击运行这个
├── settings.template.json   ← DeepSeek 配置模板
├── skills/                  ← 离线 Skill 文件（无需 GitHub）
│   ├── browser-control/
│   ├── github-research/
│   ├── sound-notifier/
│   └── github-publisher/
└── wechat/                  ← 微信桥接模块（仅尊享版）
    ├── wechat-bridge.mjs
    ├── media-processor.py
    └── cloud_vision.py
```
