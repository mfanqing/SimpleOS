## 🎉 SimpleOS - 操作系统项目已创建

你已经拥有一个完整的、可在 QEMU 上运行的 C 语言操作系统项目！

---

## ⚡ 立即开始 (3 步)

### 1️⃣ 打开 PowerShell

在 Windows 搜索栏中搜索 "PowerShell"，右键选择"以管理员身份运行"

### 2️⃣ 安装 WSL 2

```powershell
wsl --install
```

重启电脑。

### 3️⃣ 运行自动设置

在 WSL 中：

```bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
bash setup.sh
```

**完成！** SimpleOS 会在 QEMU 中启动。

---

## 📂 项目文件一览

### 📖 文档 (阅读顺序)

1. **QUICKSTART.md** ⭐ 从这里开始
2. **PROJECT_OVERVIEW.md** - 项目结构和文件说明  
3. **WINDOWS_SETUP.md** - Windows 详细设置
4. **README.md** - 完整技术文档

### 🔧 脚本和配置

- **setup.sh** - 在 WSL 中运行的自动设置脚本
- **build.ps1** - Windows PowerShell 构建助手
- **Makefile** - 构建配置文件
- **.vscode/tasks.json** - VS Code 集成任务

### 💾 源代码

```
boot/boot.asm           → x86 引导加载程序 (512 字节)
kernel/kernel_entry.asm → 内核入口点 (32 位汇编)
kernel/kernel.c         → 内核主程序 (C 语言)
kernel/kernel.h         → 头文件
src/                    → 其他源文件
build/                  → 编译输出目录
```

---

## 🎯 常用命令

### 在 Windows PowerShell 中

```powershell
cd c:\Users\mfanq\OneDrive\Desktop\cos
.\build.ps1 build    # 编译
.\build.ps1 run      # 编译并运行
.\build.ps1 debug    # 启动调试
.\build.ps1 clean    # 清理
```

### 在 WSL 中

```bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
make clean all       # 编译
make run             # 运行
make debug           # 调试
bash setup.sh        # 一键设置和运行
```

---

## 🚀 各种启动方式

| 方式 | 命令 | 难度 | 用处 |
|------|------|------|------|
| **最简单** | `bash setup.sh` | ⭐ | 第一次设置 |
| **快速编译** | `make all && make run` | ⭐ | 日常开发 |
| **调试** | `make debug` | ⭐⭐ | 代码调试 |
| **直接运行** | `qemu-system-i386 -fda build/os.img -m 128M` | ⭐⭐⭐ | 跳过编译 |

---

## 📊 项目结构

```
SimpleOS
├── 📖 文档
│   ├── QUICKSTART.md           ⭐ 快速指南
│   ├── WINDOWS_SETUP.md        详细设置
│   ├── PROJECT_OVERVIEW.md     项目介绍
│   └── README.md               技术文档
│
├── 🔨 构建工具
│   ├── Makefile                构建配置
│   ├── setup.sh                自动设置脚本
│   └── build.ps1               PowerShell 助手
│
├── 📝 源代码
│   ├── boot/boot.asm           引导加载程序
│   ├── kernel/kernel.c         内核代码
│   ├── kernel/kernel.h         头文件
│   ├── kernel/kernel_entry.asm 内核入口
│   └── src/                    其他代码
│
└── 📦 构建输出
    └── build/                  编译输出目录
```

---

## ✨ 项目特性

✅ **完整的引导加载程序** - 512 字节 x86 引导代码  
✅ **C 语言内核** - 使用 i686-elf-gcc 编译  
✅ **VGA 显示支持** - 80x25 文本模式输出  
✅ **QEMU 兼容** - 在开源模拟器上运行  
✅ **易于扩展** - 清晰的代码结构便于添加功能  
✅ **完整文档** - 详细的设置和开发指南  

---

## 🎓 学习路径

### 初级 (第 1 周)
- ✅ 安装环境
- ✅ 编译和运行 OS
- 📖 理解引导加载程序
- 📖 了解内核基础

### 中级 (第 2-4 周)
- 🎯 添加键盘中断处理
- 🎯 实现内存管理
- 🎯 实现进程调度

### 高级 (第 5+ 周)
- 🎯 添加文件系统
- 🎯 实现网络支持
- 🎯 创建命令行 Shell

---

## 🔗 重要链接

- [OSDev 百科](https://wiki.osdev.org/) - OS 开发资源
- [GCC 交叉编译器](https://wiki.osdev.org/GCC_Cross-Compiler) - 工具链
- [x86 汇编](https://wiki.osdev.org/X86) - 处理器指令
- [QEMU 文档](https://qemu.readthedocs.io/) - 模拟器

---

## ❓ 需要帮助?

### 环境问题
参考 **WINDOWS_SETUP.md** 中的故障排除部分

### 编译错误
运行 `bash setup.sh` 重新安装所有依赖

### 理解代码
查看 **README.md** 的"它如何工作"部分

### 更多功能
参考 **README.md** 的"自定义"部分

---

## 💡 提示

1. 首次运行 `bash setup.sh` 会自动安装所有工具
2. 代码修改后只需运行 `make all && make run`
3. 使用 `make debug` 和 GDB 进行代码调试
4. 查看 `Makefile` 理解编译过程

---

## 📋 检查清单

- [ ] 已读 QUICKSTART.md
- [ ] 已安装 WSL 2
- [ ] 已运行 setup.sh
- [ ] SimpleOS 在 QEMU 中成功启动
- [ ] 看到欢迎信息和系统信息

完成这些后，你就可以开始修改代码并添加新功能了！

---

**准备好了吗？现在就运行:**
```bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos && bash setup.sh
```

祝你的 OS 开发之旅愉快! 🚀
