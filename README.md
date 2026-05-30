# offline-packager

生成 3 档定价离线安装包（88/168/298），从本地最新文件打包，自动自测。

## 一键安装

### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/shimenghan6/offline-packager/main/install.ps1 | iex"
```

### 手动安装
下载 `SKILL.md` → 放到 `~/.claude/skills/offline-packager/` → 重启 Claude Code

## 使用

对 Claude Code 说：

| 触发词 | 效果 |
|--------|------|
| `打包离线版` | 生成 3 档 ZIP |
| `重新打包` | 重新生成最新版 |
| `生成安装包` | 同上 |
| `打包ZIP` | 同上 |

## 三档定价

| 套餐 | 价格 | Skill | 微信 |
|------|:---:|:---:|:---:|
| 基础版 | ¥88 | 0 | - |
| 进阶版 | ¥168 | 3 | - |
| 尊享版 | ¥298 | 3 | 支持 |

## 包含 Skill

- browser-control — 浏览器操控
- github-research — GitHub 搜索调研
- sound-notifier — 消息音效提醒

## 自测流程

打包后自动执行 4 项检查：
1. ZIP 完整性（testzip 逐文件校验）
2. 安装器关键步骤验证
3. Skill frontmatter 有效性
4. ZIP 内文件 vs 本地最新版日期对比

四项全部 PASS 才算完成。

## License

MIT
