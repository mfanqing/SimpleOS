# SimpleOS - Windows 设置指南

## 方案 1: 使用 Windows Subsystem for Linux (WSL) - 推荐

WSL 允许你在 Windows 上运行 Linux 环境，这是编译和运行 SimpleOS 的最简单方式。

### 步骤 1: 安装 WSL 2

在 PowerShell (管理员模式) 中运行:

```powershell
wsl --install
```

这将自动安装 WSL 2 和 Ubuntu。安装完成后重启计算机。

### 步骤 2: 打开 Ubuntu 终端

在 Windows 搜索栏中搜索 "Ubuntu" 并打开 Ubuntu 应用，或在 PowerShell 中运行:

```powershell
wsl
```

### 步骤 3: 安装开发工具

在 Ubuntu 终端中运行以下命令:

```bash
sudo apt-get update
sudo apt-get install -y build-essential nasm qemu-system-x86 gcc-i686-linux-gnu binutils-i686-linux-gnu
```

### 步骤 4: 访问项目文件

在 WSL 中，你可以通过以下路径访问 Windows 文件:

```bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
```

### 步骤 5: 编译和运行

```bash
make clean
make all
make run
```

QEMU 窗口将打开，显示 SimpleOS 的欢迎信息。

---

## 方案 2: 使用 MinGW/MSYS2 - 进阶

如果你想在原生 Windows 环境中工作而不使用 WSL:

### 安装 MSYS2

1. 下载 MSYS2: https://www.msys2.org/
2. 运行安装程序并完成安装
3. 打开 MSYS2 终端

### 安装工具链

在 MSYS2 终端中:

```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-binutils nasm qemu
```

### 编译

```bash
cd /c/Users/mfanq/OneDrive/Desktop/cos
make clean
make all
make run
```

---

## 方案 3: 预编译二进制 (仅用于测试)

如果你只想快速测试 OS 而不想设置编译环境:

### 使用预构建的镜像

你可以下载预编译的 `build/os.img` 文件，直接在 QEMU 中运行:

```powershell
qemu-system-i386 -fda build\os.img -m 128M
```

---

## 快速测试

### 启动 QEMU

```bash
# 基本运行
make run

# 或直接运行已编译的镜像
qemu-system-i386 -fda build/os.img -m 128M
```

### 调试模式

```bash
make debug
```

然后在另一个终端中连接 GDB:

```bash
gdb
(gdb) target remote localhost:1234
(gdb) file build/kernel.elf
(gdb) break kernel_main
(gdb) continue
```

---

## 故障排除

### 问题: 找不到 make 命令

**解决方案**: 在 WSL 中运行 `sudo apt-get install make`

### 问题: 交叉编译器错误

**解决方案**: 确保安装了所有工具:
```bash
sudo apt-get install gcc-i686-linux-gnu binutils-i686-linux-gnu
```

### 问题: QEMU 无法启动

**解决方案**: 
- 确保 build/os.img 文件存在
- 检查 QEMU 是否正确安装
- 在 WSL 中: `sudo apt-get install qemu-system-x86`

### 问题: 磁盘镜像损坏

**解决方案**: 删除 build 目录并重新编译:
```bash
make clean
make all
```

---

## 推荐配置

| 组件 | 版本 | 平台 |
|------|------|------|
| Ubuntu | 20.04 LTS 或更新 | WSL 2 |
| GCC | 9.x 或更新 | i686-linux-gnu |
| NASM | 2.14 或更新 | - |
| QEMU | 4.2 或更新 | - |
| Make | 4.2 或更新 | - |

---

## 完整 WSL 设置脚本

保存为 `setup.sh` 并在 WSL 中运行:

```bash
#!/bin/bash
set -e

echo "=== SimpleOS WSL 设置 ==="
echo "正在更新包管理器..."
sudo apt-get update

echo "正在安装编译工具..."
sudo apt-get install -y build-essential nasm qemu-system-x86 gcc-i686-linux-gnu binutils-i686-linux-gnu gdb

echo "正在导航到项目目录..."
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos

echo "正在清理旧的构建文件..."
make clean

echo "正在编译 SimpleOS..."
make all

echo "=== 编译完成! ==="
echo "要运行 OS，请执行: make run"
echo "要调试 OS，请执行: make debug"
```

运行方式:

```bash
chmod +x setup.sh
./setup.sh
```

---

## 后续步骤

编译完成后，你可以:

1. **查看输出**: QEMU 窗口会显示 SimpleOS 的欢迎信息
2. **修改内核**: 编辑 `kernel/kernel.c` 并运行 `make all` 重新编译
3. **添加功能**: 参考 README.md 中的自定义部分
4. **调试**: 使用 GDB 设置断点和单步调试

---

## 获取帮助

- OSDev Wiki: https://wiki.osdev.org/
- GCC 交叉编译指南: https://wiki.osdev.org/GCC_Cross-Compiler
- QEMU 文档: https://qemu.readthedocs.io/
