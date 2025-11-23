.PHONY: all clean run debug

# Tools
ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-i386

# Flags
CFLAGS = -ffreestanding -fno-pie -m32 -Wno-implicit-function-declaration
ASMFLAGS = -f elf32
LDFLAGS = -m elf_i386 -Ttext 0x1000

# Output
BOOT_BIN = build/boot.bin
KERNEL_OBJS = build/kernel_entry.o build/kernel.o build/keyboard.o build/memory.o build/timer.o build/shell.o build/disk.o build/devices.o build/graphics.o
KERNEL_ELF = build/kernel.elf
OS_IMG = build/os.img

# Targets
all: $(OS_IMG)

$(BOOT_BIN): boot/boot.asm
	$(ASM) -f bin $< -o $@

build/kernel_entry.o: kernel/kernel_entry.asm
	$(ASM) $(ASMFLAGS) $< -o $@

build/kernel.o: kernel/kernel.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/keyboard.o: kernel/keyboard.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/memory.o: kernel/memory.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/timer.o: kernel/timer.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/shell.o: kernel/shell.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/disk.o: kernel/disk.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/devices.o: kernel/devices.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

build/graphics.o: kernel/graphics.c kernel/kernel.h
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

$(OS_IMG): $(BOOT_BIN) $(KERNEL_ELF)
	# Create disk image
	dd if=/dev/zero of=$@ bs=512 count=2880
	# Write bootloader
	dd if=$(BOOT_BIN) of=$@ conv=notrunc
	# Extract kernel binary from ELF
	$(OBJCOPY) -O binary $(KERNEL_ELF) build/kernel.bin
	# Write kernel at sector 2
	dd if=build/kernel.bin of=$@ bs=512 seek=1 conv=notrunc

run: $(OS_IMG)
	$(QEMU) -fda $< -m 128M

debug: $(OS_IMG)
	$(QEMU) -fda $< -m 128M -S -gdb tcp::1234

clean:
	rm -f $(BOOT_BIN) build/*.o $(KERNEL_ELF) build/*.bin $(OS_IMG)

