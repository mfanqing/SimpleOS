@echo off
REM SimpleOS Test Runner for Windows
REM This script attempts to run SimpleOS in QEMU
REM Requires: QEMU installed and in PATH

setlocal enabledelayedexpansion

echo ============================================
echo    SimpleOS QEMU Test Runner
echo ============================================
echo.

REM Check if build exists
if not exist "build\os.img" (
    echo ERROR: build/os.img not found
    echo Please run 'make clean all' first
    pause
    exit /b 1
)

echo Build file found: build/os.img
echo File size: 
for /f "delims=" %%A in ('dir /b "build\os.img"') do (
    echo [OK] Build is ready
)
echo.

REM Check if QEMU is available
where qemu-system-i386 >nul 2>&1
if !errorlevel! equ 0 (
    echo [OK] QEMU found in PATH
    echo.
    echo Starting SimpleOS in QEMU...
    echo Press Ctrl+A then C to open QEMU monitor
    echo Type 'quit' in monitor to exit QEMU
    echo.
    pause
    
    qemu-system-i386 -fda build/os.img -m 128M
    
) else (
    echo [ERROR] QEMU not found in PATH
    echo.
    echo Please install QEMU first:
    echo.
    echo Option 1 (Recommended): Install in WSL
    echo   1. Open PowerShell
    echo   2. Run: wsl
    echo   3. Run: sudo apt update ^&^& sudo apt install -y qemu-system-i386
    echo   4. Run: qemu-system-i386 -fda build/os.img -m 128M
    echo.
    echo Option 2: Download from https://www.qemu.org/download/
    echo   1. Download Windows installer
    echo   2. Run installer
    echo   3. Add installation path to system PATH
    echo   4. Restart PowerShell and run this script again
    echo.
    pause
    exit /b 1
)

endlocal
