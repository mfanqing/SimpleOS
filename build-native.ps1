# SimpleOS Windows PowerShell Build System
# 这个脚本提供原生 Windows 构建支持

$ErrorActionPreference = "Stop"

# 项目路径
$ProjectDir = $PSScriptRoot
$BuildDir = Join-Path $ProjectDir "build"
$BootAsm = Join-Path $ProjectDir "boot" "boot.asm"
$KernelC = Join-Path $ProjectDir "kernel" "kernel.c"
$KernelEntryAsm = Join-Path $ProjectDir "kernel" "kernel_entry.asm"

# 输出文件
$BootBin = Join-Path $BuildDir "boot.bin"
$KernelObj = Join-Path $BuildDir "kernel_entry.o"
$KernelCObj = Join-Path $BuildDir "kernel.o"
$KernelElf = Join-Path $BuildDir "kernel.elf"
$KernelBin = Join-Path $BuildDir "kernel.bin"
$OsImg = Join-Path $BuildDir "os.img"

# 工具路径（可自定义）
$NASM = "nasm"
$GCC = "i686-elf-gcc"
$LD = "i686-elf-ld"
$OBJCOPY = "i686-elf-objcopy"
$QEMU = "qemu-system-i386"

# 编译标志
$CFLAGS = @("-ffreestanding", "-fno-pie", "-m32", "-Wno-implicit-function-declaration")
$LDFLAGS = "-m elf_i386 -Ttext 0x1000"

function Show-Help {
    Write-Host @"
SimpleOS Windows 构建系统

用法: .\build-native.ps1 [命令] [选项]

命令:
    build       - 编译 OS
    run         - 编译并在 QEMU 中运行
    debug       - 启动调试模式
    clean       - 清理构建文件
    check-tools - 检查所需工具
    help        - 显示帮助

示例:
    .\build-native.ps1 build
    .\build-native.ps1 run
    .\build-native.ps1 debug

说明:
    需要安装以下工具:
    - NASM (汇编器)
    - i686-elf-gcc (交叉编译器)
    - i686-elf-ld (链接器)
    - i686-elf-objcopy (二进制工具)
    - QEMU i386 (模拟器)

    下载地址:
    - NASM: https://www.nasm.us/
    - GCC: https://wiki.osdev.org/GCC_Cross-Compiler
    - QEMU: https://qemu.weilnetz.de/
"@
}

function Check-Tool {
    param([string]$ToolName)
    
    try {
        $result = & $ToolName --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $ToolName 已安装" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "✗ $ToolName 未找到" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✗ $ToolName 未找到" -ForegroundColor Red
    return $false
}

function Check-Tools {
    Write-Host "检查构建工具..." -ForegroundColor Cyan
    Write-Host ""
    
    $allFound = $true
    $allFound = (Check-Tool $NASM) -and $allFound
    $allFound = (Check-Tool $GCC) -and $allFound
    $allFound = (Check-Tool $LD) -and $allFound
    $allFound = (Check-Tool $OBJCOPY) -and $allFound
    $allFound = (Check-Tool $QEMU) -and $allFound
    
    Write-Host ""
    if ($allFound) {
        Write-Host "所有工具已安装！" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "某些工具未安装。请参考帮助信息。" -ForegroundColor Yellow
        return $false
    }
}

function Clean-Build {
    Write-Host "清理构建文件..." -ForegroundColor Yellow
    if (Test-Path $BuildDir) {
        Remove-Item -Path $BuildDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $BuildDir -Force > $null
    Write-Host "清理完成！" -ForegroundColor Green
}

function Build-OS {
    Write-Host "开始构建 SimpleOS..." -ForegroundColor Cyan
    Write-Host ""
    
    # 创建构建目录
    if (-not (Test-Path $BuildDir)) {
        New-Item -ItemType Directory -Path $BuildDir -Force > $null
    }
    
    # 检查工具
    Write-Host "[1/6] 检查构建工具..." -ForegroundColor Cyan
    if (-not (Check-Tools)) {
        Write-Host "构建失败：某些工具未安装" -ForegroundColor Red
        return $false
    }
    Write-Host "✓ 工具检查完成" -ForegroundColor Green
    Write-Host ""
    
    # 汇编引导加载程序
    Write-Host "[2/6] 汇编引导加载程序..." -ForegroundColor Cyan
    try {
        & $NASM -f bin $BootAsm -o $BootBin 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "汇编引导加载程序失败"
        }
        Write-Host "✓ 引导加载程序已生成: $BootBin" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ 汇编失败: $_" -ForegroundColor Red
        return $false
    }
    Write-Host ""
    
    # 汇编内核入口
    Write-Host "[3/6] 汇编内核入口..." -ForegroundColor Cyan
    try {
        & $NASM -f elf32 $KernelEntryAsm -o $KernelObj 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "汇编内核入口失败"
        }
        Write-Host "✓ 内核入口已生成: $KernelObj" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ 汇编失败: $_" -ForegroundColor Red
        return $false
    }
    Write-Host ""
    
    # 编译 C 内核
    Write-Host "[4/6] 编译 C 内核..." -ForegroundColor Cyan
    try {
        & $GCC @CFLAGS -c $KernelC -o $KernelCObj 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "编译内核失败"
        }
        Write-Host "✓ 内核已编译: $KernelCObj" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ 编译失败: $_" -ForegroundColor Red
        return $false
    }
    Write-Host ""
    
    # 链接内核
    Write-Host "[5/6] 链接内核..." -ForegroundColor Cyan
    try {
        $LDArgs = $LDFLAGS -split '\s+'
        & $LD @LDArgs $KernelObj $KernelCObj -o $KernelElf 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "链接内核失败"
        }
        Write-Host "✓ 内核已链接: $KernelElf" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ 链接失败: $_" -ForegroundColor Red
        return $false
    }
    Write-Host ""
    
    # 创建磁盘镜像
    Write-Host "[6/6] 创建磁盘镜像..." -ForegroundColor Cyan
    try {
        # 提取内核二进制
        & $OBJCOPY -O binary $KernelElf $KernelBin 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "提取二进制失败"
        }
        
        # 创建 1.44 MB 磁盘镜像 (2880 sectors × 512 bytes)
        $DiskSize = 1474560
        $bootData = [System.IO.File]::ReadAllBytes($BootBin)
        $kernelData = [System.IO.File]::ReadAllBytes($KernelBin)
        
        # 创建空镜像
        $diskImage = New-Object Byte[] $DiskSize
        
        # 写入引导加载程序（偏移 0）
        [Array]::Copy($bootData, 0, $diskImage, 0, $bootData.Length)
        
        # 写入内核（偏移 1024 = sector 2）
        [Array]::Copy($kernelData, 0, $diskImage, 1024, $kernelData.Length)
        
        # 保存镜像
        [System.IO.File]::WriteAllBytes($OsImg, $diskImage)
        
        Write-Host "✓ 磁盘镜像已创建: $OsImg" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ 创建镜像失败: $_" -ForegroundColor Red
        return $false
    }
    Write-Host ""
    
    Write-Host "构建完成！" -ForegroundColor Green
    return $true
}

function Run-OS {
    if (-not (Build-OS)) {
        return
    }
    
    Write-Host ""
    Write-Host "启动 QEMU..." -ForegroundColor Green
    Write-Host ""
    
    & $QEMU -fda $OsImg -m 128M
}

function Debug-OS {
    if (-not (Build-OS)) {
        return
    }
    
    Write-Host ""
    Write-Host "启动调试模式..." -ForegroundColor Green
    Write-Host "调试服务器: localhost:1234" -ForegroundColor Cyan
    Write-Host ""
    
    Start-Process -FilePath $QEMU -ArgumentList "-fda", $OsImg, "-m", "128M", "-S", "-gdb", "tcp::1234"
    
    Write-Host ""
    Write-Host "连接 GDB:" -ForegroundColor Yellow
    Write-Host "  gdb $KernelElf"
    Write-Host "  (gdb) target remote localhost:1234"
    Write-Host "  (gdb) break kernel_main"
    Write-Host "  (gdb) continue"
    Write-Host ""
}

# 主函数
function Main {
    param([string]$Cmd)
    
    switch ($Cmd.ToLower()) {
        "build" {
            Build-OS > $null
        }
        "run" {
            Run-OS
        }
        "debug" {
            Debug-OS
        }
        "clean" {
            Clean-Build
        }
        "check-tools" {
            Check-Tools > $null
        }
        "help" {
            Show-Help
        }
        default {
            Write-Host "未知命令: $Cmd" -ForegroundColor Red
            Write-Host "运行 '.\build-native.ps1 help' 查看帮助" -ForegroundColor Yellow
        }
    }
}

# 运行主函数
Main $Command
