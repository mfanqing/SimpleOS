# SimpleOS Build Helper for Windows
# 这个脚本帮助在 Windows 上构建和运行 SimpleOS
# 支持 WSL 和原生 Windows 构建

param(
    [string]$Command = "help",
    [switch]$UseWSL = $false
)

function Show-Help {
    Write-Host @"
SimpleOS Windows 构建助手

用法: .\build.ps1 [命令]

命令:
    build       - 在 WSL 中编译 OS
    run         - 在 WSL 中编译并运行 OS
    debug       - 在 WSL 中启动调试模式
    clean       - 清理构建文件
    wsl         - 打开 WSL 中的项目目录
    help        - 显示此帮助信息

示例:
    .\build.ps1 build   # 编译
    .\build.ps1 run     # 编译并运行
    .\build.ps1 debug   # 调试模式

注意: 需要先安装 WSL 2 并配置开发环境
    参考: WINDOWS_SETUP.md
"@
}

function Test-WSL {
    $wslTest = wsl --list 2>$null
    if ($?) {
        return $true
    }
    else {
        Write-Host "❌ WSL 未安装或无法访问" -ForegroundColor Red
        Write-Host "请先安装 WSL 2: https://docs.microsoft.com/windows/wsl/install" -ForegroundColor Yellow
        return $false
    }
}

function Invoke-WSLCommand {
    param([string]$Command)
    
    if (-not (Test-WSL)) {
        exit 1
    }
    
    $projectPath = "/mnt/c/Users/mfanq/OneDrive/Desktop/cos"
    $fullCommand = "cd $projectPath && $Command"
    
    Write-Host "📋 执行: $Command" -ForegroundColor Cyan
    wsl bash -c $fullCommand
}

switch ($Command) {
    "build" {
        Write-Host "🔨 开始编译..." -ForegroundColor Green
        Invoke-WSLCommand "make clean && make all"
        Write-Host "✅ 编译完成!" -ForegroundColor Green
    }
    
    "run" {
        Write-Host "🚀 编译并运行..." -ForegroundColor Green
        Invoke-WSLCommand "make clean && make all && make run"
    }
    
    "debug" {
        Write-Host "🐛 启动调试模式..." -ForegroundColor Green
        Invoke-WSLCommand "make debug &"
        Write-Host "ℹ️  调试服务器启动在 localhost:1234" -ForegroundColor Cyan
        Write-Host "💡 在另一个终端中运行: gdb build/kernel.elf" -ForegroundColor Cyan
    }
    
    "clean" {
        Write-Host "🧹 清理构建文件..." -ForegroundColor Yellow
        Invoke-WSLCommand "make clean"
        Write-Host "✅ 清理完成!" -ForegroundColor Green
    }
    
    "wsl" {
        Write-Host "🖥️  打开 WSL 终端..." -ForegroundColor Green
        wsl bash -c "cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos && bash"
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "❌ 未知命令: $Command" -ForegroundColor Red
        Write-Host "运行 '.\build.ps1 help' 查看帮助" -ForegroundColor Yellow
    }
}
