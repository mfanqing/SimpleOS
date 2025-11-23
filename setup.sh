#!/bin/bash
# SimpleOS WSL 2 自动设置脚本
# 在 WSL Ubuntu 终端中运行此脚本来设置完整的开发环境

set -e

echo "╔════════════════════════════════════════════╗"
echo "║  SimpleOS - WSL 2 自动设置脚本              ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否在 WSL 中
if ! grep -qi microsoft /proc/version; then
    echo -e "${RED}❌ 错误: 此脚本必须在 WSL 中运行${NC}"
    exit 1
fi

echo -e "${BLUE}📦 更新包管理器...${NC}"
sudo apt-get update -qq
echo -e "${GREEN}✅ 完成${NC}"
echo ""

echo -e "${BLUE}⚙️  安装必要的编译工具...${NC}"
sudo apt-get install -y -qq \
    build-essential \
    nasm \
    qemu-system-x86 \
    gcc-i686-linux-gnu \
    binutils-i686-linux-gnu \
    gdb \
    wget \
    curl

echo -e "${GREEN}✅ 完成${NC}"
echo ""

# 验证安装
echo -e "${BLUE}🔍 验证工具安装...${NC}"
echo ""

check_tool() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
        $1 --version 2>&1 | head -1 | sed 's/^/  /'
    else
        echo -e "${RED}✗${NC} $1 未找到"
    fi
}

check_tool "make"
check_tool "nasm"
check_tool "qemu-system-i386"
check_tool "i686-linux-gnu-gcc"
check_tool "i686-linux-gnu-ld"
check_tool "gdb"

echo ""
echo -e "${BLUE}📂 导航到项目目录...${NC}"
PROJECT_PATH="/mnt/c/Users/mfanq/OneDrive/Desktop/cos"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ 错误: 项目目录不存在: $PROJECT_PATH${NC}"
    echo -e "${YELLOW}请检查路径是否正确${NC}"
    exit 1
fi

cd "$PROJECT_PATH"
echo -e "${GREEN}✅ 已切换到: $(pwd)${NC}"
echo ""

echo -e "${BLUE}🧹 清理旧的构建文件...${NC}"
make clean > /dev/null 2>&1 || true
echo -e "${GREEN}✅ 完成${NC}"
echo ""

echo -e "${BLUE}🔨 编译 SimpleOS...${NC}"
if make all; then
    echo -e "${GREEN}✅ 编译成功!${NC}"
else
    echo -e "${RED}❌ 编译失败${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉 设置完成!                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

echo "📋 可用命令:"
echo ""
echo -e "  ${YELLOW}make run${NC}      - 在 QEMU 中运行 SimpleOS"
echo -e "  ${YELLOW}make debug${NC}    - 启动调试模式 (GDB)"
echo -e "  ${YELLOW}make clean${NC}    - 清理构建文件"
echo -e "  ${YELLOW}make all${NC}      - 重新编译"
echo ""

echo "🚀 立即运行 SimpleOS:"
echo "  $ make run"
echo ""

echo "🐛 调试 SimpleOS:"
echo "  $ make debug"
echo "  # 在另一个终端中: gdb build/kernel.elf"
echo ""

# 提示用户
read -p "是否要现在运行 SimpleOS? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🚀 启动 QEMU...${NC}"
    make run
fi
