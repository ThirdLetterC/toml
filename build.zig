const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe = b.addExecutable(.{
        .name = "simple",
        .root_module = module,
    });

    module.addIncludePath(b.path("src"));
    module.addCSourceFiles(.{
        .files = &.{ "simple/simple.c", "src/toml.c" },
        .flags = &.{
            "-std=c23",
            "-D_XOPEN_SOURCE=600",
            "-D_POSIX_C_SOURCE=200112L",
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Werror",
            "-Wstrict-prototypes",
            "-Wwrite-strings",
            "-Wno-missing-field-initializers",
            "-fPIC",
        },
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.setCwd(b.path("simple"));
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the simple example");
    run_step.dependOn(&run_cmd.step);
}
