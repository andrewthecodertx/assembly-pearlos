# Directories
BOOTLOADER_DIR = src/bootloader
KERNEL_DIR = src/kernel
BUILD_DIR = build

# Files
BOOTLOADER_SRC = $(BOOTLOADER_DIR)/boot.asm
KERNEL_SRC = $(KERNEL_DIR)/kernel.c
LINKER_SCRIPT = $(KERNEL_DIR)/linker.ld

BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
OS_IMAGE = $(BUILD_DIR)/os-image.bin

# Tools
NASM = nasm
GCC = gcc
LD = ld
QEMU = qemu-system-x86_64

# Flags
NASM_FLAGS = -f bin
GCC_FLAGS = -ffreestanding -m64 -c
LD_FLAGS = -n -T $(LINKER_SCRIPT)

# Build rules
all: $(OS_IMAGE)

$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	$(NASM) $(NASM_FLAGS) -o $@ $<

$(KERNEL_OBJ): $(KERNEL_SRC)
	$(GCC) $(GCC_FLAGS) -o $@ $<

$(KERNEL_BIN): $(KERNEL_OBJ)
	$(LD) $(LD_FLAGS) -o $@ $<

$(OS_IMAGE): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	cat $^ > $@

run: $(OS_IMAGE)
	$(QEMU) -fda $<

clean:
	rm -f $(BUILD_DIR)/*

.PHONY: all run clean
