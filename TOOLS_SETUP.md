# SimpleOS - Windows 工具安装向导

本项目在 Windows 上需要特定的工具。这个指南将帮助你安装它们。

## 方案选择

### 方案 A: 使用 WSL 2 (推荐) ⭐

**优点**: 最简单，自动化工具安装  
**时间**: ~5 分钟  
**难度**: ⭐ 简单

**步骤:**

1. 打开 PowerShell (管理员模式)
2. 运行:
   ```powershell
   wsl --install
   ```
3. 重启计算机
4. 打开 Ubuntu 应用或运行 `wsl`
5. 执行:
   ```bash
   cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
   bash setup.sh
   ```

**之后使用:**
```powershell
.\build.ps1 build    # 在 WSL 中编译
.\build.ps1 run      # 在 WSL 中编译并运行
```

---

### 方案 B: 原生 Windows (高级)

**优点**: 不需要 WSL，原生 Windows 环境  
**时间**: ~20 分钟  
**难度**: ⭐⭐ 中等

#### 步骤 1: 安装 NASM

1. 下载: https://www.nasm.us/
2. 选择 Windows 版本 (nasm-2.16-installer.exe 或最新版本)
3. 运行安装程序，选择安装到 `C:\nasm`
4. 将 `C:\nasm` 添加到 PATH:
   - 打开"系统属性" → "环境变量"
   - 找到 PATH 变量，点击编辑
   - 添加 `C:\nasm`
   - 点击确定

#### 步骤 2: 安装交叉编译器

**选项 1: 预编译二进制 (最简单)**

从以下地址下载预编译的 i686-elf 工具链:
- https://xpack.github.io/riscv-none-elf-gcc/ (虽然是 RISC-V，但思路相同)
- 或搜索 "i686-elf-gcc windows binary"

**选项 2: 使用 MinGW-w64**

1. 下载 MinGW-w64: https://www.mingw-w64.org/
2. 运行安装程序
3. 选择:
   - Architecture: i686
   - Threads: posix
   - Exception: dwarf
4. 安装到 `C:\mingw32`
5. 将 `C:\mingw32\bin` 添加到 PATH

**选项 3: MSYS2 (推荐)**

MSYS2 提供完整的开发环境。

1. 下载 MSYS2: https://www.msys2.org/
2. 运行安装程序，默认安装到 `C:\msys64`
3. 打开 MSYS2 终端
4. 运行:
   ```bash
   pacman -Sy
   pacman -S mingw-w64-i686-gcc mingw-w64-i686-binutils nasm
   ```
5. 添加 `C:\msys64\mingw32\bin` 到 PATH

#### 步骤 3: 安装 QEMU

1. 下载: https://qemu.weilnetz.de/
2. 运行安装程序
3. 选择完整安装
4. 将 QEMU 安装目录添加到 PATH

#### 步骤 4: 验证安装

打开 PowerShell 并运行:

```powershell
cd c:\Users\mfanq\OneDrive\Desktop\cos
.\build-native.ps1 check-tools
```

所有工具都应该显示 ✓

#### 步骤 5: 编译和运行

```powershell
.\build-native.ps1 build      # 编译
.\build-native.ps1 run        # 编译并运行
.\build-native.ps1 debug      # 调试
```

---

### 方案 C: Docker (备选)

如果你有 Docker 桌面版，可以在容器中构建。

1. 安装 Docker Desktop: https://www.docker.com/products/docker-desktop
2. 创建 Dockerfile (如需要可提供)
3. 在 Docker 中运行构建

---

## 快速参考

| 方案 | 时间 | 难度 | 依赖 |
|------|------|------|------|
| A: WSL 2 | 5 分钟 | ⭐ | WSL 2 |
| B: 原生 Windows | 20 分钟 | ⭐⭐ | NASM, GCC, QEMU |
| C: Docker | 10 分钟 | ⭐⭐ | Docker |

**推荐**: 方案 A (WSL 2) - 最简单、最可靠

---

## 故障排除

### 错误: "nasm: command not found"

**解决方案**:
- 确保 NASM 已安装
- 确保 NASM 目录在 PATH 中
- 重启 PowerShell

验证:
```powershell
nasm --version
```

### 错误: "i686-elf-gcc: command not found"

**解决方案**:
- 安装交叉编译器
- 确保编译器目录在 PATH 中
- 从 OSDev Wiki 下载预编译版本

验证:
```powershell
i686-elf-gcc --version
```

### 错误: "qemu-system-i386: command not found"

**解决方案**:
- 安装 QEMU
- 确保 QEMU 目录在 PATH 中

验证:
```powershell
qemu-system-i386 --version
```

### PATH 环境变量怎样设置?

1. 按 `Win + X` 选择"系统"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到 PATH
5. 点击"编辑"
6. 点击"新建"
7. 输入工具目录路径 (例如 `C:\nasm`)
8. 点击"确定"

---

## 完整工具链配置

### WSL 2 推荐 (自动安装)

```bash
sudo apt-get update
sudo apt-get install -y build-essential nasm qemu-system-x86 gcc-i686-linux-gnu binutils-i686-linux-gnu gdb
```

### Windows 原生 (手动安装)

| 工具 | 用途 | 下载地址 |
|------|------|---------|
| NASM | 汇编器 | https://www.nasm.us/ |
| i686-elf-gcc | 交叉编译器 | https://wiki.osdev.org/GCC_Cross-Compiler |
| i686-elf-ld | 链接器 | (与编译器一起) |
| i686-elf-objcopy | 二进制工具 | (与编译器一起) |
| QEMU | 模拟器 | https://qemu.weilnetz.de/ |

---

## 建议的学习路径

1. **第一步**: 选择方案 A (WSL 2)
2. **第二步**: 运行 `bash setup.sh` 自动安装
3. **第三步**: 运行 `make run` 查看 OS 启动
4. **第四步**: 修改代码并重新编译

如果 WSL 有问题，再尝试方案 B (原生 Windows)。

---

## 需要帮助?

- 查看 OSDev Wiki: https://wiki.osdev.org/
- GCC 交叉编译器指南: https://wiki.osdev.org/GCC_Cross-Compiler
- NASM 文档: https://www.nasm.us/doc/
- QEMU 文档: https://qemu.readthedocs.io/
