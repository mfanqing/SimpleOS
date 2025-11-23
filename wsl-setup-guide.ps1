# SimpleOS 编译 - WSL 安装指导
# 请按步骤操作

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     SimpleOS - 需要安装 WSL                               ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "❌ 当前检测结果:" -ForegroundColor Red
Write-Host "  • NASM: 未安装"
Write-Host "  • i686-elf-gcc: 未安装"
Write-Host "  • i686-elf-ld: 未安装"
Write-Host "  • i686-elf-objcopy: 未安装"
Write-Host "  • QEMU: 未安装"
Write-Host ""

Write-Host "💡 解决方案:" -ForegroundColor Cyan
Write-Host "Windows 上编译 x86 裸机操作系统需要 WSL (Windows Subsystem for Linux)" -ForegroundColor White
Write-Host ""

Write-Host "📋 安装步骤 (需要管理员权限):" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  右键点击 PowerShell" -ForegroundColor Magenta
Write-Host "   选择: '以管理员身份运行'" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  在管理员 PowerShell 中运行:" -ForegroundColor Magenta
Write-Host "   wsl --install -d Ubuntu" -ForegroundColor Cyan
Write-Host ""

Write-Host "3️⃣  按提示操作（可能需要重启）" -ForegroundColor Magenta
Write-Host ""

Write-Host "4️⃣  重启后，打开 WSL:" -ForegroundColor Magenta
Write-Host "   wsl" -ForegroundColor Cyan
Write-Host ""

Write-Host "5️⃣  在 WSL 中进入项目并编译:" -ForegroundColor Magenta
Write-Host "   cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos" -ForegroundColor Cyan
Write-Host "   bash compile.sh" -ForegroundColor Cyan
Write-Host ""

Write-Host "═" * 60 -ForegroundColor Magenta
Write-Host ""
Write-Host "🔗 详细说明请查看: COMPILE_GUIDE.txt" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  WSL 安装通常需要 5-10 分钟" -ForegroundColor Yellow
Write-Host ""

# 提供快速链接
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $adminCheck) {
    Write-Host "⚠️  注意: 当前 PowerShell 不是管理员模式!" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell 重新打开并选择'以管理员身份运行'" -ForegroundColor Yellow
}
