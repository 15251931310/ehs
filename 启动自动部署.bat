@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo ================================================
echo    启动EHS看板自动部署监控
echo ================================================
echo.
echo 正在启动PowerShell监控脚本...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0auto-deploy.ps1"

pause
