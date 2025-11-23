# SimpleOS - Copilot Instructions

## Project Overview
SimpleOS is a minimal operating system written in C and x86 assembly that runs on QEMU. It includes a bootloader, kernel, and basic display support.

## Project Status

- [x] Verify copilot-instructions.md created
- [x] Project requirements clarified
- [x] Project scaffolded with bootloader, kernel, and build system
- [x] Created setup guides for Windows (WINDOWS_SETUP.md, QUICKSTART.md)
- [x] Created WSL setup script (setup.sh)
- [x] Created PowerShell build helper (build.ps1)
- [ ] Install required tools and run on target platform
- [ ] Verify compilation and QEMU execution
- [ ] Complete documentation

## Development Guidelines

1. **Bootloader** (`boot/boot.asm`):
   - Must be exactly 512 bytes
   - Loads kernel from disk sector 2
   - Transfers control to kernel at 0x1000

2. **Kernel** (`kernel/kernel.c`):
   - Compiled with `-ffreestanding` flag
   - Uses VGA memory at 0xB8000
   - 80x25 text mode display

3. **Build System**:
   - Uses NASM for assembly
   - i686-elf-gcc cross-compiler
   - Generates bootable floppy image

## Build Requirements

- NASM assembler
- i686-elf-gcc cross-compiler
- QEMU i386 emulator
- GNU Make

## Compilation

```bash
make clean
make all
make run
```

## Testing

- Run `make run` to start OS in QEMU
- Run `make debug` for GDB debugging
- Verify kernel displays welcome message

## File Organization

- `boot/` - Bootloader code (x86 16-bit)
- `kernel/` - Kernel code (x86 32-bit, C and assembly)
- `src/` - Additional kernel modules
- `build/` - Build artifacts
- `.vscode/` - VS Code configuration

## Next Steps

1. Set up development environment with required tools
2. Test compilation and QEMU execution
3. Add keyboard interrupt support
4. Implement memory management
5. Add file system support
