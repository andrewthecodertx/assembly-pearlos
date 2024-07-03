# PearlOS Bootloader

PearlOS Bootloader is a simple, yet powerful, proof of concept for the initial stage of the PearlOS operating system. Designed with simplicity in mind, it aims to lay the foundational groundwork for a minimalistic operating system. This bootloader is responsible for setting the stage for the kernel, which is the next development milestone in the PearlOS project.

## Features

- **16-bit Real Mode**: The bootloader is written in 16-bit real mode assembly, which is the initial mode of the x86 processor after booting. This mode is used to set up the system for the transition to 32-bit protected mode.
- **Minimalistic**: The bootloader is designed to be as minimalistic as possible, with the goal of providing the essential functionality required to load the kernel.
- **FAT12 Filesystem Support**: The bootloader includes support for reading files from a FAT12 filesystem, which is commonly used for floppy disks and other legacy storage media.
- **Modular Design**: The bootloader is designed to be modular, with separate files for different components such as the boot sector, the file loader, and the kernel entry point.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- NASM (The Netwide Assembler) for compiling the assembly source code.
- DOSFSTOOLS (DOS File System Tools) for reading and writing files to disk.
- MTOOLS
- QEMU (Quick Emulator) for running the bootloader in a virtual machine.
- Optionally, a physical floppy disk or a floppy disk image for testing on real hardware.

### Building

To compile the PearlOS bootloader and generate the bootable image, run the following command...
```bash
make all
```
### Running

To run the bootloader in QEMU, execute the following command...
```bash
qemu-system-x86_64 -drive format=raw,file=build/PearlOS_bootloader.img
```

If you prefer to test it on physical hardware, you can write the image to a floppy disk or a USB drive using dd (Linux or macOS) or a tool like Rufus (Windows). Be very careful with this operation as it can overwrite the contents of the disk.

Using `dd` on Linux or macOS:
```bash
dd if=build/PearlOS_bootloader.img of=/dev/sdX bs=512 count=1
```

Replace `/dev/sdX` with the correct device identifier for your floppy disk or USB drive. **Double-check the device identifier to avoid data loss.**

## Contributing

Contributions are welcome and appreciated.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
