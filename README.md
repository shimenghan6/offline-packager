# offline-packager

> 说一句"打包离线版"，3 个 ZIP 直接生成到桌面。88/168/298 三档定价，CRLF 换行、call 命令、括号转义——安装器踩过的坑全帮你填好了。

**ZIP 打包 · .bat 安装器 · CRLF 强制 · 空白环境自愈 · 4 项自测零问题才算完**

### 谁需要这个

| 你 | 为什么你需要 |
|----|------------|
| 卖远程安装服务 | 一键生成三档定价 ZIP，客户拿到就能装 |
| 维护多个 skill | 从本地最新文件打包，绝不会塞旧版本 |
| 不想管打包细节 | 4 个坑（CRLF/call/括号/Node.js 阻断）已自动处理 |

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
| 进阶版 | ¥168 | 4 | - |
| 尊享版 | ¥298 | 4 | 支持 |

## 包含 Skill

- browser-control — 浏览器操控
- github-research — GitHub 搜索调研
- sound-notifier — 消息音效提醒
- github-publisher — GitHub 发布管理

### Before/After（安装器质量）

| 之前（手动写 .bat） | 之后（offline-packager 自动处理） |
|---------|-------|
| LF 换行 cmd 乱码 | 强制 CRLF，zip 内验证 |
| npm/code 不加 call 中断脚本 | 全部 call 前缀 |
| echo (...) if 块内语法错误 | `^(` `^)` 自动转义 |
| Node.js 失败 skill 也没装 | WARN 继续，skill 照装不误 |

## 自测流程

打包后自动执行 4 项检查：
1. ZIP 完整性（testzip 逐文件校验）
2. 安装器关键步骤验证
3. Skill frontmatter 有效性
4. ZIP 内文件 vs 本地最新版日期对比

四项全部 PASS 才算完成。

## License

MIT
