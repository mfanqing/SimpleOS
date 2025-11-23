# 🚀 SimpleOS - 快速开始 (Quick Start)

## 现在的状态 (Current Status)

✅ **系统已修复**  
✅ **编译成功**  
✅ **磁盘镜像已生成**  
⏳ **等待在QEMU中运行**

---

## 立即运行 (Run Now)

### 方法1: 最简单 (Recommended)

#### 在Windows中:

```powershell
# 打开PowerShell，运行:
.\run-qemu.ps1
```

#### 在WSL中:

```bash
wsl
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
qemu-system-i386 -fda build/os.img -m 128M
```

### 方法2: 使用Make

```bash
make run
```

### 方法3: 直接命令

```powershell
qemu-system-i386 -fda build/os.img -m 128M
```

---

## 在QEMU中做什么 (What to Do in QEMU)

### 第1步: 观察启动过程

您应该看到:
```
SimpleOS Bootloader loaded...
Entering protected mode...

Welcome to SimpleOS!
Type 'help' for commands.

SimpleOS>
```

### 第2步: 尝试这些命令

```
SimpleOS> help              # 显示所有命令
SimpleOS> graphics          # ⭐ 查看图形界面！
SimpleOS> stats             # 显示统计
SimpleOS> memory            # 显示内存
SimpleOS> echo Hello!       # 打印文本
SimpleOS> halt              # 关闭系统
```

---

## QEMU未安装? (QEMU Not Installed?)

### WSL方式（推荐）

```bash
wsl
sudo apt update
sudo apt install -y qemu-system-i386
```

然后运行:
```bash
qemu-system-i386 -fda build/os.img -m 128M
```

### Windows方式

1. 访问: https://www.qemu.org/download/
2. 下载Windows安装程序
3. 运行安装程序
4. 重启PowerShell
5. 运行脚本

### Winget (Windows 11+)

```powershell
winget install qemu
```

---

## 修复了什么 (What Was Fixed)

❌ **旧问题:** 系统卡在"SimpleOS Bootloader loaded..."

✅ **修复:**
- 驱动器号改为 0x00 (软驱)
- 增加读取扇区数到30
- 添加错误检查

✅ **结果:** 内核应该能正常加载和运行

---

## 完整指南 (Full Guides)

- 📖 `BUILD_STATUS.md` - 详细的修复报告
- 📖 `QEMU_INSTALL.md` - QEMU安装完整指南
- 📖 `BOOTLOADER_FIX.md` - 引导加载程序修复说明
- 📖 `README.md` - 项目概述

---

## 命令参考 (Command Reference)

| 命令 | 说明 |
|------|------|
| `help` | 显示帮助 |
| `graphics` | 图形演示 ⭐ |
| `stats` | 系统统计 |
| `memory` | 内存信息 |
| `cpu` | CPU信息 |
| `time` | 系统时间 |
| `clear` | 清屏 |
| `echo <文本>` | 打印文本 |
| `halt` | 关闭 |

---

## 常见问题 (FAQ)

**Q: QEMU说"找不到设备"?**  
A: 确保 build/os.img 存在 (1.44 MB)

**Q: 卡在启动中?**  
A: 这表示修复成功了！输入命令

**Q: 如何退出QEMU?**  
A: 输入 `halt` 或按 Ctrl+Q

**Q: 图形界面怎么看?**  
A: 输入 `graphics` 命令

---

## 文件位置 (File Locations)

```
C:\Users\mfanq\OneDrive\Desktop\cos\
├── run-qemu.ps1           ← 运行脚本
├── run-qemu.bat           ← 或使用此脚本
├── BUILD_STATUS.md        ← 详细报告
├── QEMU_INSTALL.md        ← 安装指南
├── BOOTLOADER_FIX.md      ← 修复说明
└── build/
    └── os.img             ← 磁盘镜像（就是这个！）
```

---

## TL;DR (太长不读)

1. **检查QEMU是否安装:**
   ```powershell
   qemu-system-i386 --version
   ```

2. **如未安装:**
   ```bash
   wsl; sudo apt install -y qemu-system-i386
   ```

3. **运行系统:**
   ```powershell
   .\run-qemu.ps1
   # 或
   qemu-system-i386 -fda build/os.img -m 128M
   ```

4. **尝试:**
   ```
   SimpleOS> graphics
   SimpleOS> stats
   SimpleOS> halt
   ```

---

**准备好了吗？** 🎮  
运行 `.\run-qemu.ps1` 开始！
