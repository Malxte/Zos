const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
    });

    const optimize = b.standardOptimizeOption(.{});

    // Kernel compilation step (as before)
    const boot_obj = b.addSystemCommand(&.{
        "nasm", "-f", "elf32", "-o", "zig-out/boot.o", "src/boot.asm",
    });

    const exe = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.addObjectFile(b.path("zig-out/boot.o"));
    exe.step.dependOn(&boot_obj.step);
    exe.setLinkerScript(b.path("src/linker.ld"));

    b.installArtifact(exe);

    // ISO creation step
    const iso_step = b.step("iso", "Create a bootable ISO image");

    // Create ISO directory structure
    const iso_dir = "zig-out/iso";
    const mkdir_cmd = b.addSystemCommand(&.{
        "mkdir", "-p", iso_dir ++ "/boot/grub",
    });

    // Copy kernel to ISO directory
    const copy_kernel_cmd = b.addSystemCommand(&.{
        "cp", "zig-out/bin/kernel.elf", iso_dir ++ "/boot/kernel.elf",
    });
    copy_kernel_cmd.step.dependOn(b.getInstallStep()); // Correct dependency
    copy_kernel_cmd.step.dependOn(&mkdir_cmd.step);

    // Copy grub.cfg to ISO directory
    const copy_grub_cmd = b.addSystemCommand(&.{
        "cp", "src/grub.cfg", iso_dir ++ "/boot/grub/grub.cfg",
    });
    copy_grub_cmd.step.dependOn(&mkdir_cmd.step);

    // Run grub-mkrescue
    const grub_cmd = b.addSystemCommand(&.{
        "grub-mkrescue", "-o", "zig-out/kernel.iso", iso_dir,
    });
    grub_cmd.step.dependOn(&copy_kernel_cmd.step);
    grub_cmd.step.dependOn(&copy_grub_cmd.step);

    iso_step.dependOn(&grub_cmd.step);
}