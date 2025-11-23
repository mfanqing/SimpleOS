# SimpleOS 快速启动指南

> 适用于 Windows 10/11 用户

## ⚡ 最快的方式 (5 分钟)

### 1️⃣ 安装 WSL 2

在 PowerShell (管理员模式) 中运行:

```powershell
wsl --install
```

重启计算机。

### 2️⃣ 打开 WSL 终端

搜索并打开 "Ubuntu" 应用 (或在 PowerShell 中运行 `wsl`)

### 3️⃣ 一键设置

在 WSL 终端中运行:

```bash
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos
bash setup.sh
```

### 4️⃣ 查看结果

SimpleOS 应该在 QEMU 中启动，显示欢迎信息!

---

## 📊 总结

| 步骤 | 时间 | 难度 |
|------|------|------|
| 安装 WSL 2 | 2-3 分钟 | ⭐ 简单 |
| 打开 WSL | 30 秒 | ⭐ 简单 |
| 运行 setup.sh | 2-3 分钟 | ⭐ 简单 |
| **总计** | **~5 分钟** | **⭐ 简单** |

---

## 🎯 常用命令

在 WSL 中进入项目目录后:

```bash
# 编译
make clean && make all

# 运行
make run

# 调试
make debug
```

---

## ❓ 常见问题

**Q: WSL 安装失败?**
A: 确保 Windows 10 版本为 2004 或更新版本。运行 `winver` 查看版本。

**Q: 编译失败?**
A: 运行 `setup.sh` 再次尝试安装所有依赖。

**Q: QEMU 没有启动?**
A: 检查 `build/os.img` 文件是否存在。运行 `make clean && make all`。

---

## 📚 更多信息

- 详细设置: 查看 `WINDOWS_SETUP.md`
- 项目介绍: 查看 `README.md`
- 调试指南: 查看 `README.md` 的调试部分

---

## 🔗 有用的链接

- [WSL 官方文档](https://docs.microsoft.com/windows/wsl/)
- [OSDev Wiki](https://wiki.osdev.org/)
- [QEMU 文档](https://qemu.readthedocs.io/)
