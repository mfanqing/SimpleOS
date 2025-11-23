# SimpleOS - A Minimal Operating System in C

A simple operating system written in C and x86 assembly that can run on QEMU.

## Features

- **Bootloader**: 512-byte x86 bootloader (boot.asm)
- **Kernel**: Basic kernel written in C with VGA display support
- **QEMU Compatible**: Runs on QEMU i386 emulator

## Project Structure

```
cos/
├── boot/
│   └── boot.asm          # x86 bootloader
├── kernel/
│   ├── kernel.c          # Main kernel code
│   ├── kernel.h          # Kernel headers
│   └── kernel_entry.asm  # Kernel entry point (32-bit)
├── src/                  # Additional source files
├── build/                # Build output directory
├── Makefile             # Build configuration
└── README.md            # This file
```

## Requirements

### Linux/macOS

- `nasm` - Netwide Assembler for bootloader
- `i686-elf-gcc` - Cross-compiler for x86
- `i686-elf-binutils` - Binutils for cross-compilation
- `qemu-system-i386` - QEMU i386 emulator

### Windows (WSL Recommended)

If using Windows, install WSL and use the Linux instructions, or use Windows native tools:

- NASM (Windows binary available)
- Cross-compiler toolchain
- QEMU for Windows

#### Installation on Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y nasm qemu-system-x86 build-essential
```

To install i686-elf cross-compiler:

```bash
sudo apt-get install -y gcc-i686-linux-gnu binutils-i686-linux-gnu
```

Or build from source (see: https://wiki.osdev.org/GCC_Cross-Compiler)

## Building

```bash
make clean
make all
```

This will:
1. Assemble the bootloader (`boot/boot.asm`)
2. Compile the kernel code (`kernel/kernel.c`)
3. Link everything together
4. Create a bootable disk image (`build/os.img`)

## Running

### Basic Run

```bash
make run
```

### Debug Mode

```bash
make debug
```

Then connect with GDB:

```bash
gdb
(gdb) target remote localhost:1234
(gdb) file build/kernel.elf
(gdb) break kernel_main
(gdb) continue
```

## How It Works

1. **Bootloader** (boot.asm)
   - Executes at 0x7C00 in real mode
   - Loads the kernel from disk sectors
   - Switches execution to kernel

2. **Kernel** (kernel_entry.asm + kernel.c)
   - Entry point at 0x1000 in protected mode
   - Sets up stack and basic environment
   - Calls C code `kernel_main()`
   - Displays welcome message on VGA console

3. **Display**
   - Uses VGA memory buffer (0xB8000)
   - 80x25 text mode
   - White text on black background

## Customization

### Adding Features

- **Add drivers**: Create new .c files in `kernel/` and include in Makefile
- **Add system calls**: Extend `kernel.c` with interrupt handlers
- **Add memory management**: Implement paging and page allocator
- **Add scheduler**: Implement process/task scheduling

### Modifying Boot Parameters

Edit `Makefile` variables:
- `LDFLAGS` - Linker flags and text address
- `CFLAGS` - Compiler optimization flags
- `QEMU` parameters in `run` target

## References

- [OSDev Wiki](https://wiki.osdev.org/)
- [Intel x86 Architecture](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [QEMU Documentation](https://qemu.readthedocs.io/)
- [NASM Manual](https://www.nasm.us/doc/)

## License

This project is provided as-is for educational purposes.

## Troubleshooting

### "i686-elf-gcc not found"

Install the cross-compiler toolchain:

```bash
# Debian/Ubuntu
sudo apt-get install gcc-i686-linux-gnu

# Or build from source
```

### "qemu-system-i386 not found"

Install QEMU:

```bash
sudo apt-get install qemu-system-x86
```

### Kernel doesn't start

- Verify bootloader is at offset 0x7C00
- Check kernel binary at sector 2
- Verify 0x1000 is correct load address in kernel_entry.asm

## Next Steps

- Implement keyboard interrupt handler
- Add file system support
- Implement process scheduling
- Add memory management (paging, virtual memory)
- Create system call interface
