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
| 进阶版 | ¥168 | 4 | ✗ |
| 尊享版 | ¥298 | 4 | ✓ |

## Skill 名称映射（关键）

```
'sound-notifier' → 'claude-code-sound-notifier'
'browser-control' → 'browser-control'
'github-research' → 'github-research'
'github-publisher' → 'github-publisher'
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

---

## ★ .bat 安装器踩坑记录（3 次排查才全过）

### 坑 1：ZIP 打包后换行符变 LF，cmd.exe 完全不执行

**现象**：Python `zipfile.write()` 写入 .bat 文件后，ZIP 内的文件换行符从 CRLF 变成 LF。Windows `cmd.exe` 无法识别 LF 换行，脚本直接乱码退出。

**根因**：Python 文本模式读取文件时自动转换了换行符，或者 `write()` 没有保留原始二进制。

**解决**：打包前强制转换，用 `writestr()` 二进制写入。

```python
# 读取源文件并强制 CRLF
bat_raw = INSTALLER.read_bytes()
bat_raw = bat_raw.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')

# 用 writestr 写入 ZIP（不是 write）
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
    zf.writestr('install-offline.bat', bat_raw)
```

**验证**：
```python
with zipfile.ZipFile(zip_path, 'r') as zf:
    bat = zf.read('install-offline.bat')
    assert bat.count(b'\r\n') > 300, "CRLF missing!"
    assert bat.count(b'\n') - bat.count(b'\r\n') == 0, "LF-only lines!"
```

---

### 坑 2：npm/code 是 .cmd 文件，不加 call 直接终止父脚本

**现象**：安装器执行到 `npm install` 或 `code --install-extension` 时直接退出，后续所有步骤消失。Exit code 0 或 255。

**根因**：`npm` 和 `code` 在 Windows 上实际是 `npm.cmd` 和 `code.cmd`（批处理文件）。在 .bat 中直接调用另一个 .cmd/.bat 而不加 `call`，控制权永久转移，父脚本不再执行。

**解决**：所有外部命令统一加 `call`，无论它是不是 .cmd。

```bat
:: 错误
npm install -g xxx
code --install-extension xxx

:: 正确
call npm install -g xxx
call code --install-extension xxx
call winget install xxx
call powershell -Command "..."
```

**影响的外部命令**：`npm`, `code`, `winget`（exe 但加 call 无害）, `powershell`（exe 但加 call 无害）

---

### 坑 3：echo (...) 在 if 块内，括号被当成嵌套块（真凶！）

**现象**：即使加了 `call` 和 CRLF，执行到 `if !OK_NODE! equ 1 (` 后立即报错：`... was unexpected at this time.` Exit code 255。

**排查过程**：
1. 孤立 if 块测试 → 通过 ✗（不是 if 的问题）
2. echo ON 逐行追踪 → 断在 `echo   Installing via npm (needs network, may take 1-2 min)...`
3. 对比测试 → `echo with (...)` FAIL, `echo without ()` PASS, `echo with ^(^)` PASS

**根因**：cmd.exe 解析器在 `if` 块内看到 `echo ... (...)...` 时，把 `(` 当成嵌套块开始标记。即使它在 echo 文本中也不行。需要通过 `^` 转义。

**解决**：if 块内所有 echo 中的 `()` 必须转义为 `^(` 和 `^)`。

```bat
:: 错误 — 在 if 块内，cmd 把 (needs 当成嵌套块
if !OK_NODE! equ 1 (
    echo   Installing via npm (needs network)...
)

:: 正确 — 转义括号
if !OK_NODE! equ 1 (
    echo   Installing via npm ^(needs network^)...
)
```

**受影响的行（3 处）**：
```
L105: echo   Installing via npm ^(needs network, may take 1-2 min^)...
L230: echo        Need Deluxe ^(298 yuan^) edition.
L298: echo   Download: https://nodejs.org ^(LTS version^)
```

---

### 坑 4：Node.js 安装失败直接退出，skill 文件也没装

**现象**：空白电脑上 winget 故障 → Node.js 安装失败 → `exit /b 1` 退出。后面 skill 安装（纯文件复制，不依赖 Node.js）全部跳过。

**解决**：Node.js 失败改为 WARN，继续执行。Skill 文件复制不需要任何运行环境。

```bat
:: 错误
if node_failed (
    pause
    exit /b 1
)

:: 正确
if node_failed (
    echo   [WARN] Node.js install failed.
    echo   [WARN] Skills will install, but Claude Code needs Node.js.
)
```

同时增加 `OK_NODE`, `OK_VSCODE`, `OK_CLAUDE` 等状态变量，在最后的 Installation Summary 中清晰展示缺什么。

---

### 打包自检清单（新增 bat 专项）

打包后必须通过以下全部检查：

```
□ ZIP testzip 无损坏
□ ZIP 内 .bat 文件 CRLF 行数 > 300, LF-only = 0
□ bat 内容包含: call npm, call code, call winget, call powershell
□ bat 内容包含: ^(转义括号
□ bat 内容包含: Installation Summary + How to Use Each Skill
□ bat 内容包含: [0/6] 到 [6/6] 全部 7 步
□ bat 内容包含: set OK_NODE=0, set OK_VSCODE=0, set OK_CLAUDE=0
□ 真实环境执行：7 步全通 + Summary + Guide 出现
□ 空白环境执行：Node.js 失败后 skill 仍然安装成功
□ ZIP vs 本地源文件大小完全一致
```

---

### 坑 5：中文 bat 的 UTF-8 输出 + 状态标签全中文化（2026-06-02）

**背景**：用户要求安装器全部显示中文，不要再混杂英文状态标签。同时 ZIP 内需要附带中文说明文件。

**实施内容**：

| 原来 | 改为 |
|------|------|
| `[OK]` / `[WARN]` / `[SKIP]` / `[ERROR]` / `[RETRY]` / `[INFO]` | `[完成]` / `[警告]` / `[跳过]` / `[错误]` / `[重试]` / `[提示]` |
| `Installation Summary` | `安装总结` |
| `How to Use Each Skill` | `Skill 使用方法` |
| `Say: "open browser..."` | `说："打开浏览器搜索 xxx"` |
| 所有步骤描述、错误提示、使用指南 | 全部中文化 |

**关键注意事项**：

1. **`chcp 65001` 后输出是 UTF-8**：bat 脚本开头有 `chcp 65001 >nul 2>&1`，所以 Python 子进程读取输出时必须用 `decode('utf-8')`，不能用 GBK。

2. **中文括号不需要转义**：中文全角括号 `（）` 不会触发 cmd 的块解析，建议在中文 echo 中优先使用全角括号，避免 `^` 转义。

3. **状态栏用全角符号**：`（1=已装 0=未装）` 比 `(1=ok, 0=missing)` 更自然，也不需要转义。

4. **Skill 使用指南也要中文化**：每个 skill 的描述和触发词示例都要翻译，让纯中文用户看得懂。

5. **附带 `README_CN.md`**：每个 ZIP 内都要包含一份中文使用说明，内容包括安装步骤、三档对比、常见问题、文件结构。

**打包时额外包含的文件**：

```python
# README_CN.md 随 bat 一起打入 ZIP
zf.writestr('install-offline.bat', bat_raw)
zf.write(CONFIG, 'settings.template.json')
zf.write(README_CN, 'README_CN.md')  # ← 新增
```

**验证要点**：

```
□ bat 内容包含中文状态标签: [完成] [警告] [跳过] [重试] [提示]
□ bat 内容包含: 安装总结, Skill 使用方法
□ bat 内容包含: 所有 7 步描述为中文
□ 执行输出用 UTF-8 解码后: 安装总结 + Skill 使用方法 均显示正常
□ ZIP 内包含 README_CN.md
□ 三个档位全部通过执行测试
```

---

### 打包完整自检清单（汇总）

```
□ ZIP testzip 无损坏
□ ZIP 内 .bat 文件 CRLF > 300, LF-only = 0
□ bat: call npm, call code, call winget, call powershell
□ bat: ^( 转义括号
□ bat: [完成]/[警告]/[跳过]/[重试]/[提示] 中文标签
□ bat: 安装总结 + Skill 使用方法
□ bat: [0/6]~[6/6] 全部 7 步
□ bat: set OK_NODE=0, OK_VSCODE=0, OK_CLAUDE=0
□ ZIP 内包含 README_CN.md + settings.template.json
□ 真实执行：7 步全通 + 中文总结/指南正常
□ 空白环境：Node.js 失败后 skill 仍安装
□ ZIP vs 本地源文件大小一致
□ 三个档位全部通过测试
```
