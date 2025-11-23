# SimpleOS - Windows 自动编译脚本
# 这个脚本会自动安装 WSL、配置环境并编译 SimpleOS

param(
    [switch]$SkipWSL = $false,
    [switch]$NoRun = $false
)

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "❌ 错误: 此脚本需要管理员权限" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell 并选择'以管理员身份运行'" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     SimpleOS - Windows 自动编译脚本                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$projectPath = "c:\Users\mfanq\OneDrive\Desktop\cos"

# 步骤 1: 检查 WSL
Write-Host "[1/5] 检查 WSL 状态..." -ForegroundColor Cyan

$wslInstalled = $false
try {
    $wslTest = wsl --list 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ($wslTest -notmatch "没有已安装的分发") {
            $wslInstalled = $true
            Write-Host "✓ WSL 已安装" -ForegroundColor Green
        }
    }
}
catch {
    # WSL 未安装
}

if (-not $wslInstalled) {
    if ($SkipWSL) {
        Write-Host "❌ WSL 未安装且被要求跳过" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "⏳ 安装 WSL 2..." -ForegroundColor Yellow
    $installOutput = wsl --install -d Ubuntu --no-launch 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ WSL 已安装" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  请重启计算机来完成 WSL 安装" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "重启后，请运行以下命令:" -ForegroundColor Cyan
        Write-Host "  cd $projectPath" -ForegroundColor Gray
        Write-Host "  bash compile.sh" -ForegroundColor Gray
        Write-Host ""
        exit 0
    }
    else {
        Write-Host "❌ WSL 安装失败" -ForegroundColor Red
        Write-Host $installOutput
        exit 1
    }
}

Write-Host ""

# 步骤 2: 验证项目目录
Write-Host "[2/5] 验证项目目录..." -ForegroundColor Cyan
if (-not (Test-Path $projectPath)) {
    Write-Host "❌ 项目目录不存在: $projectPath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 项目目录: $projectPath" -ForegroundColor Green
Write-Host ""

# 步骤 3: 在 WSL 中执行编译
Write-Host "[3/5] 在 WSL 中安装工具和编译..." -ForegroundColor Cyan
Write-Host ""

$compileScript = Join-Path $projectPath "compile.sh"
if (-not (Test-Path $compileScript)) {
    Write-Host "❌ 编译脚本不存在" -ForegroundColor Red
    exit 1
}

# 转换路径为 WSL 格式
$wslPath = "/mnt/c/Users/mfanq/OneDrive/Desktop/cos"

# 在 WSL 中运行编译脚本
$compileCmd = "cd $wslPath && bash compile.sh"
wsl bash -c $compileCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ 编译成功！" -ForegroundColor Green
    Write-Host ""
    
    # 验证输出文件
    $osImg = Join-Path $projectPath "build" "os.img"
    if (Test-Path $osImg) {
        $imgSize = (Get-Item $osImg).Length
        Write-Host "✓ 磁盘镜像: $osImg ($('{0:N0}' -f $imgSize) 字节)" -ForegroundColor Green
    }
}
else {
    Write-Host ""
    Write-Host "❌ 编译失败" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 步骤 4: 提示用户
Write-Host "[4/5] 后续步骤..." -ForegroundColor Cyan
Write-Host ""
Write-Host "编译已完成！可用命令:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  在 WSL 中运行:" -ForegroundColor Cyan
Write-Host "    wsl" -ForegroundColor Gray
Write-Host "    cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos" -ForegroundColor Gray
Write-Host ""
Write-Host "  运行 SimpleOS:" -ForegroundColor Cyan
Write-Host "    make run" -ForegroundColor Gray
Write-Host ""
Write-Host "  调试模式:" -ForegroundColor Cyan
Write-Host "    make debug" -ForegroundColor Gray
Write-Host ""
Write-Host "  查看源代码:" -ForegroundColor Cyan
Write-Host "    kernel/kernel.c" -ForegroundColor Gray
Write-Host "    boot/boot.asm" -ForegroundColor Gray
Write-Host ""

Write-Host "[5/5] 完成" -ForegroundColor Cyan
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              ✅ SimpleOS 已编译完成!                      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
