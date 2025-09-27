# MyOS

A simple Zig kernel for x86.

## Dependencies

To build this project, you need:

- `zig`
- `nasm`
- `grub` (specifically `grub-mkrescue`)
- `xorriso`
- `mtools`

## Build Instructions

There are two main build steps available:

### 1. Compile the Kernel

This command compiles the kernel into an ELF file located at `zig-out/bin/kernel.elf`.

```sh
zig build
```

### 2. Create a Bootable ISO

This command compiles the kernel and then packages it into a bootable ISO file located at `zig-out/kernel.iso`. This ISO can be run in a virtual machine or burned to a USB drive.

```sh
zig build iso
```

## Running in QEMU

After creating the ISO, you can test it with QEMU:

```sh
qemu-system-i386 -cdrom zig-out/kernel.iso
```

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

Copyright (C) 2025 Malxte
