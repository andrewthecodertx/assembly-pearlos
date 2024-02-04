BOOTLOADER_SRC = src/bootloader/boot.asm
KERNEL_SRC = src/kernel/main.asm

BOOTLOADER_BIN = build/bootloader.bin
KERNEL_BIN = build/kernel.bin

FLOPPY_IMG = build/PearlOS_bootloader_beta.img

.PHONY: all clean setup build_bin build_floppy cleanbin

all: clean setup build_bin build_floppy cleanbin

setup: 
	mkdir -p build

build_bin: ${BOOTLOADER_BIN} ${KERNEL_BIN}

${BOOTLOADER_BIN}: ${BOOTLOADER_SRC}
	nasm $< -f bin -o $@

${KERNEL_BIN}: ${KERNEL_SRC}
	nasm $< -f bin -o $@

build_floppy: ${FLOPPY_IMG}

${FLOPPY_IMG}: ${BOOTLOADER_BIN} ${KERNEL_BIN}
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F12 $@
	dd if=${BOOTLOADER_BIN} of=$@ conv=notrunc
	mcopy -i $@ ${KERNEL_BIN} "::kernel.bin"
	chown 1000:1000 $@

clean:
	rm -rf build/*

cleanbin:
	rm -f ${BOOTLOADER_BIN} ${KERNEL_BIN}
