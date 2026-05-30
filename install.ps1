# offline-packager - 一键安装脚本
# 将此 Claude Code Skill 安装到本地

$SKILL_NAME = "offline-packager"
$SKILLS_DIR = "$env:USERPROFILE\.claude\skills\$SKILL_NAME"

Write-Host "=== offline-packager 一键安装 ===" -ForegroundColor Cyan

# 创建 skills 目录
if (-not (Test-Path $SKILLS_DIR)) {
    New-Item -ItemType Directory -Path $SKILLS_DIR -Force | Out-Null
    Write-Host "[OK] 创建目录: $SKILLS_DIR" -ForegroundColor Green
}

# 下载 SKILL.md
$url = "https://raw.githubusercontent.com/shimenghan6/offline-packager/main/SKILL.md"
Write-Host "[..] 下载 SKILL.md ..."
try {
    Invoke-WebRequest -Uri $url -OutFile "$SKILLS_DIR\SKILL.md" -UseBasicParsing
    Write-Host "[OK] SKILL.md 安装完成" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] 下载失败: $_" -ForegroundColor Red
    Write-Host "请手动从 https://github.com/shimenghan6/offline-packager 下载" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Cyan
Write-Host "对 Claude Code 说：打包离线版" -ForegroundColor White
Write-Host "触发词：打包离线版 / 生成安装包 / 打包ZIP / 重新打包" -ForegroundColor Gray
