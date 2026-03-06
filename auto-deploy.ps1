# EHS看板自动部署监控脚本
# 监控index.html文件变化，自动推送到GitHub并更新网页

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   EHS看板自动部署监控已启动" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "监控文件: index.html" -ForegroundColor Yellow
Write-Host "监控目录: $PSScriptRoot" -ForegroundColor Yellow
Write-Host ""
Write-Host "每次保存HTML文件后，将自动推送到GitHub" -ForegroundColor Green
Write-Host "按 Ctrl+C 停止监控" -ForegroundColor Red
Write-Host ""

# 设置工作目录
Set-Location $PSScriptRoot

# 创建文件监控器
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $PSScriptRoot
$watcher.Filter = "index.html"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

# 防抖动变量（避免重复触发）
$lastTriggerTime = [DateTime]::MinValue
$debounceSeconds = 2

# 定义文件变化时的处理函数
$action = {
    $currentTime = Get-Date
    $timeSinceLastTrigger = ($currentTime - $script:lastTriggerTime).TotalSeconds

    # 防抖动：如果距离上次触发少于2秒，则忽略
    if ($timeSinceLastTrigger -lt $script:debounceSeconds) {
        return
    }

    $script:lastTriggerTime = $currentTime

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "检测到文件变化！开始自动部署..." -ForegroundColor Yellow
    Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""

    try {
        # 添加文件到Git
        Write-Host "[1/3] 添加文件到Git..." -ForegroundColor Cyan
        git add index.html

        # 创建提交
        Write-Host "[2/3] 创建提交..." -ForegroundColor Cyan
        $commitMessage = "自动更新EHS看板 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m "$commitMessage`n`nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

        # 推送到GitHub
        Write-Host "[3/3] 推送到GitHub..." -ForegroundColor Cyan
        git push origin main

        Write-Host ""
        Write-Host "✓ 部署成功！" -ForegroundColor Green
        Write-Host "网站将在1-2分钟后更新: https://15251931310.github.io/ehs/" -ForegroundColor Green

    } catch {
        Write-Host ""
        Write-Host "✗ 部署失败: $_" -ForegroundColor Red
    }

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "继续监控中..." -ForegroundColor Yellow
}

# 注册事件处理器
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action | Out-Null

# 保持脚本运行
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # 清理资源
    $watcher.Dispose()
}
