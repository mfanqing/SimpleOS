@echo off
REM SimpleOS Windows Build Script
REM 这个脚本用于在 Windows 上编译 SimpleOS
REM 需要安装: NASM, MinGW/MSYS2, QEMU

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0"
set "BUILD_DIR=%PROJECT_DIR%build"
set "BOOT_ASM=%PROJECT_DIR%boot\boot.asm"
set "KERNEL_C=%PROJECT_DIR%kernel\kernel.c"
set "KERNEL_ENTRY_ASM=%PROJECT_DIR%kernel\kernel_entry.asm"
set "KERNEL_H=%PROJECT_DIR%kernel\kernel.h"

set "BOOT_BIN=%BUILD_DIR%\boot.bin"
set "KERNEL_OBJ=%BUILD_DIR%\kernel_entry.o"
set "KERNEL_C_OBJ=%BUILD_DIR%\kernel.o"
set "KERNEL_ELF=%BUILD_DIR%\kernel.elf"
set "KERNEL_BIN=%BUILD_DIR%\kernel.bin"
set "OS_IMG=%BUILD_DIR%\os.img"

REM 工具
set "NASM=nasm"
set "GCC=i686-elf-gcc"
set "LD=i686-elf-ld"
set "OBJCOPY=i686-elf-objcopy"
set "DD=dd"
set "QEMU=qemu-system-i386"

REM 编译标志
set "CFLAGS=-ffreestanding -fno-pie -m32 -Wno-implicit-function-declaration"
set "LDFLAGS=-m elf_i386 -Ttext 0x1000"

if "%1"=="" goto help
if "%1"=="build" goto build
if "%1"=="run" goto run
if "%1"=="clean" goto clean
if "%1"=="debug" goto debug
if "%1"=="help" goto help

:help
echo.
echo SimpleOS Windows Build Script
echo.
echo Usage: build.bat [command]
echo.
echo Commands:
echo   build   - Compile SimpleOS
echo   run     - Compile and run in QEMU
echo   clean   - Remove build artifacts
echo   debug   - Run with GDB debugging
echo   help    - Show this help message
echo.
echo Example:
echo   build.bat build
echo   build.bat run
echo.
goto end

:clean
echo.
echo [*] Cleaning build artifacts...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
echo [+] Clean complete!
goto end

:build
echo.
echo [*] Building SimpleOS...
echo.

REM Check if build directory exists
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM Check for required tools
where /q %NASM%
if errorlevel 1 (
    echo [-] Error: NASM not found. Please install NASM.
    goto end
)

where /q %GCC%
if errorlevel 1 (
    echo [-] Error: %GCC% not found. Please install i686-elf-gcc cross-compiler.
    goto end
)

where /q %LD%
if errorlevel 1 (
    echo [-] Error: %LD% not found. Please install i686-elf-ld.
    goto end
)

REM Assemble bootloader
echo [1/5] Assembling bootloader...
%NASM% -f bin "%BOOT_ASM%" -o "%BOOT_BIN%"
if errorlevel 1 (
    echo [-] Error assembling bootloader
    goto end
)
echo [+] Bootloader assembled: %BOOT_BIN%

REM Assemble kernel entry
echo [2/5] Assembling kernel entry...
%NASM% -f elf32 "%KERNEL_ENTRY_ASM%" -o "%KERNEL_OBJ%"
if errorlevel 1 (
    echo [-] Error assembling kernel entry
    goto end
)
echo [+] Kernel entry assembled: %KERNEL_OBJ%

REM Compile kernel C code
echo [3/5] Compiling kernel...
%GCC% %CFLAGS% -c "%KERNEL_C%" -o "%KERNEL_C_OBJ%"
if errorlevel 1 (
    echo [-] Error compiling kernel
    goto end
)
echo [+] Kernel compiled: %KERNEL_C_OBJ%

REM Link kernel
echo [4/5] Linking kernel...
%LD% %LDFLAGS% "%KERNEL_OBJ%" "%KERNEL_C_OBJ%" -o "%KERNEL_ELF%"
if errorlevel 1 (
    echo [-] Error linking kernel
    goto end
)
echo [+] Kernel linked: %KERNEL_ELF%

REM Extract binary from ELF
echo [5/5] Creating disk image...
%OBJCOPY% -O binary "%KERNEL_ELF%" "%KERNEL_BIN%"
if errorlevel 1 (
    echo [-] Error extracting kernel binary
    goto end
)

REM Create disk image (floppy 1.44 MB = 2880 sectors)
if exist "%OS_IMG%" del "%OS_IMG%"

REM Using dd or Python to create disk image
REM Try using Python if available
python -c "open('%OS_IMG%', 'wb').write(b'\x00' * 1474560)" 2>nul
if errorlevel 1 (
    REM Fallback: create using PowerShell
    powershell -Command "$null | Out-File -Encoding Byte -FilePath '%OS_IMG%' -Force; $img = [System.IO.File]::Create('%OS_IMG%'); $img.SetLength(1474560); $img.Close()"
    if errorlevel 1 (
        echo [-] Error: Cannot create disk image
        goto end
    )
)

REM Write bootloader at offset 0
powershell -Command "$bytes = [System.IO.File]::ReadAllBytes('%BOOT_BIN%'); $fs = [System.IO.File]::Open('%OS_IMG%', 'Open'); $fs.Write($bytes, 0, $bytes.Length); $fs.Close()"

REM Write kernel at sector 2 (offset 1024)
powershell -Command "$bytes = [System.IO.File]::ReadAllBytes('%KERNEL_BIN%'); $fs = [System.IO.File]::Open('%OS_IMG%', 'Open'); $fs.Seek(1024, 0); $fs.Write($bytes, 0, $bytes.Length); $fs.Close()"

echo [+] Disk image created: %OS_IMG%
echo.
echo [+] Build successful!
echo.
goto end

:run
call :build
if errorlevel 1 goto end

echo.
echo [*] Starting QEMU...
echo.

where /q %QEMU%
if errorlevel 1 (
    echo [-] Error: QEMU not found. Please install QEMU.
    goto end
)

%QEMU% -fda "%OS_IMG%" -m 128M
goto end

:debug
call :build
if errorlevel 1 goto end

echo.
echo [*] Starting QEMU in debug mode...
echo [*] Debug server: localhost:1234
echo [*] Connect with: gdb build\kernel.elf
echo.

where /q %QEMU%
if errorlevel 1 (
    echo [-] Error: QEMU not found. Please install QEMU.
    goto end
)

%QEMU% -fda "%OS_IMG%" -m 128M -S -gdb tcp::1234
goto end

:end
endlocal
