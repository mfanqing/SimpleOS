# 简单编译脚本 - SimpleOS
# 这个脚本直接调用 WSL 进行编译

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     SimpleOS - 编译器                                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$projectPath = Get-Location
Write-Host "项目路径: $projectPath" -ForegroundColor Cyan
Write-Host ""

# 检查 WSL
Write-Host "[1/3] 检查 WSL..." -ForegroundColor Yellow
$wslCheck = $null
try {
    $wslCheck = & wsl echo "OK" 2>$null
    if ($LASTEXITCODE -eq 0 -and $wslCheck -eq "OK") {
        Write-Host "✓ WSL 已安装可用" -ForegroundColor Green
    } else {
        Write-Host "❌ WSL 检查失败，请先安装 WSL: wsl --install" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ WSL 未找到，请先安装 WSL" -ForegroundColor Red
    Write-Host "执行: wsl --install -d Ubuntu" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[2/3] 开始编译..." -ForegroundColor Yellow

# 转换路径
$wslPath = $projectPath -replace "C:\\", "/mnt/c/" -replace "\\", "/"

# 执行编译
& wsl bash -c "cd '$wslPath' && bash compile.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[3/3] 编译完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "✓ 编译成功！" -ForegroundColor Green
    Write-Host "编译文件位置: $projectPath\build\" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "后续步骤:" -ForegroundColor Yellow
    Write-Host "1. 验证文件: ls $projectPath\build\" -ForegroundColor White
    Write-Host "2. 运行 OS: wsl && cd '$wslPath' && make run" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ 编译失败" -ForegroundColor Red
    Write-Host "检查错误信息并确保已安装:" -ForegroundColor Yellow
    Write-Host "  • NASM 汇编器" -ForegroundColor White
    Write-Host "  • i686-elf-gcc 编译器" -ForegroundColor White
    Write-Host "  • i686-elf-ld 链接器" -ForegroundColor White
    exit 1
}
