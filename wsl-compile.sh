#!/bin/bash

# SimpleOS 自动编译脚本 (WSL)
# 自动安装工具并编译

set -e

echo "=========================================="
echo "  SimpleOS - WSL Compilation Script"
echo "=========================================="
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "[1/5] Installing build tools..."
sudo apt-get update -qq
sudo apt-get install -y -qq nasm build-essential qemu-system-i386 2>/dev/null

# Install i686-elf toolchain
if ! command -v i686-elf-gcc &> /dev/null; then
    echo "    Installing i686-elf cross-compiler..."
    sudo apt-get install -y -qq gcc-arm-linux-gnueabihf 2>/dev/null || true
    
    # Alternative: build from source or download prebuilt
    echo "    Note: i686-elf-gcc may need manual installation"
fi

echo "[2/5] Checking tools..."
which nasm > /dev/null && echo "    ✓ NASM found" || echo "    ✗ NASM missing"
which qemu-system-i386 > /dev/null && echo "    ✓ QEMU found" || echo "    ✗ QEMU missing"

echo "[3/5] Cleaning previous build..."
make clean 2>/dev/null || true

echo "[4/5] Compiling SimpleOS..."
if make all 2>&1; then
    echo ""
    echo "[5/5] Build successful!"
    echo ""
    echo "Build artifacts:"
    ls -lh build/ 2>/dev/null | tail -5
    echo ""
    echo "To run the OS:"
    echo "  make run"
    echo ""
else
    echo ""
    echo "Build failed. Check errors above."
    exit 1
fi
