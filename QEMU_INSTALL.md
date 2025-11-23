# QEMU 安装指南 (Installation Guide)

## 方法 1: 使用 WSL 2 安装 (Recommended)

```bash
# 在 WSL bash 中运行:
wsl
sudo apt update
sudo apt install -y qemu-system-i386

# 然后运行 OS:
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
qemu-system-i386 -fda build/os.img -m 128M
```

## 方法 2: 从 Windows 安装 QEMU

下载地址: https://www.qemu.org/download/

1. 访问上述链接
2. 选择 "Windows" 版本
3. 下载安装程序并运行
4. 安装完成后，在 PowerShell 中测试:
   ```powershell
   qemu-system-i386 --version
   ```

5. 然后运行:
   ```powershell
   cd C:\Users\mfanq\OneDrive\Desktop\cos
   qemu-system-i386 -fda build/os.img -m 128M
   ```

## 方法 3: 使用 vcpkg (如果已安装)

```powershell
vcpkg install qemu:x64-windows
```

## 方法 4: 使用 Winget (Windows 11+)

```powershell
winget install qemu
```

## 验证 QEMU 安装 (Verify Installation)

```powershell
qemu-system-i386 --version
```

应该输出类似:
```
QEMU emulator version X.X.X
```

## 运行 SimpleOS

一旦 QEMU 安装完成，运行:

```powershell
# 从 Windows PowerShell
cd C:\Users\mfanq\OneDrive\Desktop\cos
qemu-system-i386 -fda build/os.img -m 128M
```

或

```bash
# 从 WSL bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
qemu-system-i386 -fda build/os.img -m 128M
```

## 在 QEMU 中的操作

启动后，您应该看到:
```
SimpleOS Bootloader loaded...
Entering protected mode...

Welcome to SimpleOS!
Type 'help' for commands.

SimpleOS>
```

### 可用命令:

| 命令 | 描述 |
|------|------|
| `help` | 显示帮助信息 |
| `graphics` | 进入图形模式展示 |
| `stats` | 显示系统统计 |
| `memory` | 显示内存信息 |
| `cpu` | 显示 CPU 信息 |
| `time` | 显示当前时间 |
| `clear` | 清除屏幕 |
| `echo <text>` | 输出文本 |
| `halt` | 关闭系统 |

### 推荐测试流程:

1. 启动 QEMU
2. 看到提示符后，输入: `graphics`
3. 观看图形演示 (彩色窗口和圆形)
4. 按任意键返回 shell
5. 尝试其他命令: `stats`, `memory`, `help`
6. 最后输入 `halt` 关闭系统

---

**特别建议:** 使用 WSL 2 安装 QEMU 是最简单的方式，因为:
- WSL 已经可用
- 简单的一行命令安装
- 完全支持图形显示
