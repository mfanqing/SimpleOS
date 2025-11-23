#!/usr/bin/env pwsh
# SimpleOS QEMU Test Runner for PowerShell
# Usage: .\run-qemu.ps1

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "    SimpleOS QEMU Test Runner" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if build exists
$buildPath = "build/os.img"
if (-not (Test-Path $buildPath)) {
    Write-Host "ERROR: build/os.img not found" -ForegroundColor Red
    Write-Host "Please run 'make clean all' first"
    Read-Host "Press Enter to exit"
    exit 1
}

$imgInfo = Get-Item $buildPath
Write-Host "[OK] Build file found" -ForegroundColor Green
Write-Host "  Path: $($imgInfo.FullName)" -ForegroundColor Gray
Write-Host "  Size: $($imgInfo.Length) bytes ($(($imgInfo.Length / 512)) sectors)" -ForegroundColor Gray
Write-Host "  Modified: $($imgInfo.LastWriteTime)" -ForegroundColor Gray
Write-Host ""

# Check if QEMU is available
$qemuPath = (Get-Command qemu-system-i386 -ErrorAction SilentlyContinue)
if ($qemuPath) {
    Write-Host "[OK] QEMU found" -ForegroundColor Green
    Write-Host "  Path: $($qemuPath.Source)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Starting SimpleOS in QEMU..." -ForegroundColor Cyan
    Write-Host "  Command: qemu-system-i386 -fda build/os.img -m 128M" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  - Press Ctrl+A then C to open QEMU monitor" -ForegroundColor Gray
    Write-Host "  - Type 'quit' in monitor to exit QEMU" -ForegroundColor Gray
    Write-Host "  - Try commands: graphics, stats, help, memory" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to start QEMU"
    
    & qemu-system-i386 -fda build/os.img -m 128M
    
} else {
    Write-Host "[ERROR] QEMU not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install QEMU first:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1 (Recommended): Install in WSL" -ForegroundColor Cyan
    Write-Host "  1. Open PowerShell" -ForegroundColor Gray
    Write-Host "  2. Run: wsl" -ForegroundColor Gray
    Write-Host "  3. Run: sudo apt update && sudo apt install -y qemu-system-i386" -ForegroundColor Gray
    Write-Host "  4. Run: qemu-system-i386 -fda build/os.img -m 128M" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Option 2: Download from https://www.qemu.org/download/" -ForegroundColor Cyan
    Write-Host "  1. Download Windows installer" -ForegroundColor Gray
    Write-Host "  2. Run installer" -ForegroundColor Gray
    Write-Host "  3. Add installation directory to system PATH" -ForegroundColor Gray
    Write-Host "  4. Restart PowerShell and run this script again" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Option 3 (Windows 11+): Use Winget" -ForegroundColor Cyan
    Write-Host "  1. Run: winget install qemu" -ForegroundColor Gray
    Write-Host "  2. Run: .\\run-qemu.ps1" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Press Enter to exit"
    exit 1
}
