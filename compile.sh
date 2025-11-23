#!/bin/bash
# SimpleOS - 完整自动化设置和编译脚本

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  SimpleOS 自动设置和编译脚本                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_DIR="/mnt/c/Users/mfanq/OneDrive/Desktop/cos"

# 检查是否在 WSL 中
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo -e "${RED}❌ 错误: 此脚本必须在 WSL 中运行${NC}"
    echo "请运行: wsl --install -d Ubuntu"
    exit 1
fi

echo -e "${BLUE}📦 步骤 1/4: 更新系统包${NC}"
sudo apt-get update -qq 2>&1 | tail -1
echo -e "${GREEN}✓ 完成${NC}"
echo ""

echo -e "${BLUE}⚙️  步骤 2/4: 安装编译工具${NC}"
sudo apt-get install -y -qq \
    build-essential \
    nasm \
    qemu-system-x86 \
    gcc-i686-linux-gnu \
    binutils-i686-linux-gnu \
    gdb \
    2>&1 | tail -1

echo -e "${GREEN}✓ 工具安装完成${NC}"
echo ""

echo -e "${BLUE}📂 步骤 3/4: 进入项目目录${NC}"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ 项目目录不存在: $PROJECT_DIR${NC}"
    exit 1
fi
cd "$PROJECT_DIR"
echo -e "${GREEN}✓ 项目目录: $(pwd)${NC}"
echo ""

echo -e "${BLUE}🔨 步骤 4/4: 编译 SimpleOS${NC}"
echo ""

# 清理旧文件
make clean > /dev/null 2>&1 || true

# 编译
if make all; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              ✅ 编译成功!                                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📊 编译结果:${NC}"
    echo "  • 引导加载程序: build/boot.bin"
    echo "  • 内核 ELF: build/kernel.elf"
    echo "  • 磁盘镜像: build/os.img"
    echo ""
    echo -e "${YELLOW}🚀 运行 SimpleOS:${NC}"
    echo ""
    
    # 询问是否立即运行
    read -p "是否要现在运行 SimpleOS? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}启动 QEMU...${NC}"
        make run
    else
        echo ""
        echo -e "${YELLOW}执行以下命令来运行:${NC}"
        echo "  make run          # 运行 SimpleOS"
        echo "  make debug        # 调试模式"
        echo "  make clean        # 清理"
        echo ""
    fi
else
    echo ""
    echo -e "${RED}❌ 编译失败${NC}"
    exit 1
fi
