#!/usr/bin/env python3
# SimpleOS Windows Build System
# Python 跨平台构建脚本

import os
import sys
import subprocess
import shutil
from pathlib import Path

class SimpleOSBuilder:
    def __init__(self):
        self.project_dir = Path(__file__).parent
        self.build_dir = self.project_dir / "build"
        self.boot_asm = self.project_dir / "boot" / "boot.asm"
        self.kernel_c = self.project_dir / "kernel" / "kernel.c"
        self.kernel_entry_asm = self.project_dir / "kernel" / "kernel_entry.asm"
        
        self.boot_bin = self.build_dir / "boot.bin"
        self.kernel_obj = self.build_dir / "kernel_entry.o"
        self.kernel_c_obj = self.build_dir / "kernel.o"
        self.kernel_elf = self.build_dir / "kernel.elf"
        self.kernel_bin = self.build_dir / "kernel.bin"
        self.os_img = self.build_dir / "os.img"
        
        self.tools = {
            'nasm': 'nasm',
            'gcc': 'i686-elf-gcc',
            'ld': 'i686-elf-ld',
            'objcopy': 'i686-elf-objcopy',
            'qemu': 'qemu-system-i386'
        }
    
    def print_header(self, text):
        print(f"\n{'='*60}")
        print(f"  {text}")
        print(f"{'='*60}\n")
    
    def check_tool(self, tool_name):
        """Check if a tool is available"""
        try:
            result = subprocess.run(
                [self.tools[tool_name], '--version'],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except:
            return False
    
    def check_tools(self):
        """Check all required tools"""
        self.print_header("Checking Build Tools")
        
        all_found = True
        for name in self.tools:
            if self.check_tool(name):
                print(f"✓ {self.tools[name]} found")
            else:
                print(f"✗ {self.tools[name]} NOT found")
                all_found = False
        
        if not all_found:
            print("\nSome tools are missing!")
            print("Please run: bash setup.sh (in WSL)")
            print("Or install tools manually - see TOOLS_SETUP.md")
            return False
        
        print("\nAll tools are installed!")
        return True
    
    def clean(self):
        """Clean build artifacts"""
        self.print_header("Cleaning Build Files")
        
        if self.build_dir.exists():
            shutil.rmtree(self.build_dir)
        
        self.build_dir.mkdir(exist_ok=True)
        print("Clean complete!")
    
    def build(self):
        """Build SimpleOS"""
        self.print_header("Building SimpleOS")
        
        # Create build directory
        self.build_dir.mkdir(exist_ok=True)
        
        # Check tools
        print("[1/6] Checking tools...")
        if not self.check_tools():
            return False
        print("✓ Tools OK\n")
        
        # Assemble bootloader
        print("[2/6] Assembling bootloader...")
        try:
            subprocess.run(
                [self.tools['nasm'], '-f', 'bin', str(self.boot_asm), '-o', str(self.boot_bin)],
                check=True,
                capture_output=True
            )
            print(f"✓ Bootloader: {self.boot_bin}\n")
        except subprocess.CalledProcessError as e:
            print(f"✗ Error: {e.stderr.decode()}")
            return False
        
        # Assemble kernel entry
        print("[3/6] Assembling kernel entry...")
        try:
            subprocess.run(
                [self.tools['nasm'], '-f', 'elf32', str(self.kernel_entry_asm), '-o', str(self.kernel_obj)],
                check=True,
                capture_output=True
            )
            print(f"✓ Kernel entry: {self.kernel_obj}\n")
        except subprocess.CalledProcessError as e:
            print(f"✗ Error: {e.stderr.decode()}")
            return False
        
        # Compile C kernel
        print("[4/6] Compiling kernel...")
        try:
            cflags = ['-ffreestanding', '-fno-pie', '-m32', '-Wno-implicit-function-declaration']
            subprocess.run(
                [self.tools['gcc']] + cflags + ['-c', str(self.kernel_c), '-o', str(self.kernel_c_obj)],
                check=True,
                capture_output=True
            )
            print(f"✓ Kernel compiled: {self.kernel_c_obj}\n")
        except subprocess.CalledProcessError as e:
            print(f"✗ Error: {e.stderr.decode()}")
            return False
        
        # Link kernel
        print("[5/6] Linking kernel...")
        try:
            ldflags = ['-m', 'elf_i386', '-Ttext', '0x1000']
            subprocess.run(
                [self.tools['ld']] + ldflags + [str(self.kernel_obj), str(self.kernel_c_obj), '-o', str(self.kernel_elf)],
                check=True,
                capture_output=True
            )
            print(f"✓ Kernel linked: {self.kernel_elf}\n")
        except subprocess.CalledProcessError as e:
            print(f"✗ Error: {e.stderr.decode()}")
            return False
        
        # Create disk image
        print("[6/6] Creating disk image...")
        try:
            # Extract kernel binary
            subprocess.run(
                [self.tools['objcopy'], '-O', 'binary', str(self.kernel_elf), str(self.kernel_bin)],
                check=True,
                capture_output=True
            )
            
            # Create 1.44 MB floppy image
            disk_size = 1474560
            with open(self.os_img, 'wb') as f:
                f.write(b'\x00' * disk_size)
            
            # Write bootloader at offset 0
            with open(self.os_img, 'r+b') as f:
                with open(self.boot_bin, 'rb') as boot:
                    f.write(boot.read())
            
            # Write kernel at offset 1024 (sector 2)
            with open(self.os_img, 'r+b') as f:
                f.seek(1024)
                with open(self.kernel_bin, 'rb') as kernel:
                    f.write(kernel.read())
            
            print(f"✓ Disk image: {self.os_img}\n")
        except Exception as e:
            print(f"✗ Error: {e}")
            return False
        
        print("✓ Build successful!\n")
        return True
    
    def run(self):
        """Build and run in QEMU"""
        if not self.build():
            return False
        
        print("Starting QEMU...\n")
        try:
            subprocess.run([self.tools['qemu'], '-fda', str(self.os_img), '-m', '128M'])
        except Exception as e:
            print(f"Error: {e}")
            return False
        
        return True
    
    def debug(self):
        """Build and run with GDB"""
        if not self.build():
            return False
        
        print("Starting QEMU in debug mode...")
        print("Debug server: localhost:1234\n")
        
        try:
            subprocess.Popen(
                [self.tools['qemu'], '-fda', str(self.os_img), '-m', '128M', '-S', '-gdb', 'tcp::1234']
            )
            print("\nConnect with GDB:")
            print(f"  gdb {self.kernel_elf}")
            print("  (gdb) target remote localhost:1234")
            print("  (gdb) break kernel_main")
            print("  (gdb) continue\n")
        except Exception as e:
            print(f"Error: {e}")
            return False

def main():
    if len(sys.argv) < 2:
        command = 'help'
    else:
        command = sys.argv[1].lower()
    
    builder = SimpleOSBuilder()
    
    if command == 'build':
        builder.build()
    elif command == 'run':
        builder.run()
    elif command == 'debug':
        builder.debug()
    elif command == 'clean':
        builder.clean()
    elif command == 'check-tools':
        builder.check_tools()
    else:
        print("""
SimpleOS Build System

Usage: python build.py [command]

Commands:
    build       - Compile SimpleOS
    run         - Build and run in QEMU
    debug       - Build and start debugging
    clean       - Remove build artifacts
    check-tools - Check for required tools
    help        - Show this help message

Examples:
    python build.py build
    python build.py run
    python build.py debug
        """)

if __name__ == '__main__':
    main()
