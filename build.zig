const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allow the user to override the target from the command line
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the user to override the optimization level from the command line
    const optimize = b.standardOptimizeOption(.{});

    // Create the module
    const lib_mod = b.addModule("nbt", .{
        .optimize = optimize,
        .root_source_file = b.path("src/nbt.zig"),
    });

    // Create the static library
    const lib = b.addStaticLibrary(.{
        .name = "nbt",
        .root_source_file = b.path("src/nbt.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Install the library
    b.installArtifact(lib);

    // Create unit tests
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("test/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add the module to the tests
    lib_unit_tests.root_module.addImport("nbt", lib_mod);

    // Create a run step for the tests
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Add a test step to the build
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
