const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.addModule("nbt", .{
        .optimize = optimize,
        .root_source_file = b.path("src/nbt.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "nbt",
        .root_source_file = b.path("src/nbt.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("test/test.zig"),
        .target = target,
        .optimize = std.builtin.OptimizeMode.Debug,
    });

    lib_unit_tests.root_module.addImport("nbt", lib_mod);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    b.installArtifact(lib_unit_tests);
}
