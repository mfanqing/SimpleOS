# SimpleOS - Quick Run Guide

## ✅ Compilation Status: SUCCESS

Your SimpleOS image has been successfully compiled!
- **File:** `build/os.img`
- **Size:** 1.44 MB (bootable floppy)
- **Ready to run in QEMU**

---

## 🚀 RUN THE OS (3 Options)

### Option 1: WSL Terminal (Recommended)

```bash
# Open WSL terminal
wsl

# Navigate to project
cd /mnt/c/Users/mfanq/OneDrive/Desktop/cos

# Run the OS
make run
```

### Option 2: PowerShell (Windows)

```powershell
# Navigate to project
cd C:\Users\mfanq\OneDrive\Desktop\cos

# Set execution policy (one time)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Run the build script
.\build.ps1 run
```

### Option 3: Direct QEMU Command

```bash
qemu-system-i386 -fda /mnt/c/Users/mfanq/OneDrive/Desktop/cos/build/os.img -m 128M
```

---

## 💬 Available Commands in SimpleOS

Once the OS boots, you'll see a prompt like: `SimpleOS> `

Type these commands:

| Command | Description | Example |
|---------|-------------|---------|
| `help` | Show all commands | `SimpleOS> help` |
| `clear` | Clear the screen | `SimpleOS> clear` |
| `time` | Show system uptime | `SimpleOS> time` |
| `memory` | Show memory status | `SimpleOS> memory` |
| `cpu` | Show CPU info | `SimpleOS> cpu` |
| `stats` | Show system statistics | `SimpleOS> stats` |
| `echo` | Print text | `SimpleOS> echo hello` |
| `halt` | Shutdown the OS | `SimpleOS> halt` |

### Example Session

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Welcome to SimpleOS - Minimal x86 Operating System
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Display initialized
✓ Keyboard initialized
✓ Memory (1 MB)
✓ Timer (100 Hz)
✓ Shell ready
✓ Disk Controller

System Information:
- Architecture: x86
- Memory: 1 MB heap
- Display: 80x25 text mode (VGA)
- Features: Keyboard, Timer, Disk I/O

SimpleOS> help

Available commands:
  help    - Show available commands
  clear   - Clear screen
  time    - Display system ticks
  memory  - Show memory information
  cpu     - Show CPU information
  stats   - Display system statistics
  echo    - Echo a message
  halt    - Halt the CPU

SimpleOS> memory
Memory Status:
Total:     1024 KB
Used:      128 KB (12%)
Available: 896 KB (88%)

SimpleOS> stats
System Statistics:
  Uptime: 45678 ticks
  Memory: 128 KB / 1024 KB (12%)
  Utilization: 8%

SimpleOS> echo Hello World!
Hello World!

SimpleOS> halt
Shutting down...
```

---

## 🎯 Features to Test

1. **Display** - Colors and text rendering
2. **Keyboard** - Type commands at the prompt
3. **Memory** - Check heap allocation
4. **Timer** - Monitor uptime with `time` command
5. **Shell** - Execute all available commands
6. **Stats** - View real-time system information

---

## ⚙️ System Information

- **Architecture:** x86 (32-bit protected mode)
- **RAM:** 1 MB heap
- **Display:** 80x25 VGA text mode with 16 colors
- **Bootloader:** Sector 0 (512 bytes)
- **Kernel:** Sector 1+ (~13 KB)
- **Features:**
  - Keyboard interrupt handler
  - PIT-based timer (100 Hz)
  - Memory allocator
  - Disk I/O driver
  - Interactive shell
  - System statistics

---

## 🛑 Stopping the OS

### In QEMU Window
- **Close Button:** Click the X to close QEMU
- **Alt+F4:** Close QEMU window
- **Type `halt`:** Graceful shutdown in the shell

### From Terminal
- **Ctrl+C:** Terminate QEMU
- **Ctrl+Alt+G:** Capture/release mouse in fullscreen mode

---

## 📁 Key Files

- `build/os.img` - Your bootable OS image
- `Makefile` - Build configuration
- `kernel/kernel.c` - Main kernel code
- `kernel/keyboard.c` - Keyboard driver
- `kernel/shell.c` - Command shell
- `kernel/memory.c` - Memory manager

---

## 🐛 Troubleshooting

**Q: QEMU doesn't show up**
- A: QEMU creates a separate window. Check your taskbar for a QEMU window.

**Q: Commands don't work**
- A: Make sure you're at the `SimpleOS>` prompt. Try `help` first.

**Q: Everything freezes**
- A: This is normal - halt the OS or close QEMU. Try again.

**Q: No keyboard input**
- A: Click inside the QEMU window to ensure it has focus.

---

## 📚 Documentation

- **COMPILATION_SUCCESS.md** - Detailed compilation report
- **README.md** - Full technical documentation
- **FEATURES.md** - Feature descriptions
- **QUICKSTART.md** - Setup instructions
- **OPTIMIZATION_REPORT.txt** - Performance details

---

## ✨ What's Included

✓ Bootloader (512 bytes, loads kernel)
✓ Protected-mode kernel in C
✓ VGA text display with colors
✓ Keyboard input driver
✓ 1MB memory allocator
✓ System timer (100Hz)
✓ Interactive shell (7 commands)
✓ Disk I/O driver
✓ System statistics
✓ Performance optimizations

---

## 🎉 Ready to Go!

Your SimpleOS is compiled and ready to run. Launch it now:

```bash
make run
```

Enjoy your minimal operating system! 🚀
