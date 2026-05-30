---
name: offline-packager
description: |
  生成 3 档定价离线安装包（88/168/298）。从本地最新文件打包，自动自测。
  触发条件："打包离线版", "生成安装包", "打包ZIP", "离线包", "重新打包",
  "package offline", "生成离线安装包"
---

# 离线安装包生成

## 触发时自动执行

用户说"打包离线版"/"重新打包"时，**无需询问、一步生成**。

## 三档定价

| 套餐 | 价格 | skill | wechat |
|------|:---:|:---:|:---:|
| 基础版 | ¥88 | 0 | ✗ |
| 进阶版 | ¥168 | 3 | ✗ |
| 尊享版 | ¥298 | 3 | ✓ |

## Skill 名称映射（关键）

```
'sound-notifier' → 'claude-code-sound-notifier'
'browser-control' → 'browser-control'
'github-research' → 'github-research'
```

## 打包源路径

| 类型 | 本地路径 |
|------|------|
| 安装器 | `~/github-repos/claude-code-starter/offline/install-offline.bat` |
| 配置 | `~/github-repos/claude-code-starter/settings.template.json` |
| Skill | `~/.claude/skills/<name>/SKILL.md` |
| 微信 | `~/.claude/wechat-bridge.mjs` `media-processor.py` `cloud_vision.py` |

## 输出

`C:\Users\shish\Desktop\cc文档生成\{套餐名}-{价格}元-ClaudeCode{描述}.zip`

## ★ 打包后强制自测（不可跳过）

```
1. ZIP 完整性 — testzip 逐文件校验
2. 安装器关键步骤 — VS Code / Claude Code / DeepSeek / LocalSkills / WeChat
3. Skill 文件品质 — frontmatter 有效性 + 文件大小
4. 版本对比 — ZIP 内文件 vs 本地最新版日期
```

四项全部 PASS 才告诉用户"完成"。
