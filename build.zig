const std = @import("std");

const vkgen = @import("vulkan_zig");
const ShaderCompileStep = vkgen.ShaderCompileStep;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const maybe_override_registry = b.option([]const u8, "override-registry", "Override the path to the Vulkan registry used for the examples");

    const registry = b.dependency("vulkan_headers", .{}).path("registry/vk.xml");

    // GUI Test executable
    const gui_exe = b.addExecutable(.{
        .name = "gui_test",
        .root_source_file = b.path("src/main.zig"),
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(gui_exe);
    gui_exe.linkSystemLibrary("glfw3");
    gui_exe.linkSystemLibrary("vulkan");

    const vk_gen = b.dependency("vulkan_zig", .{}).artifact("vulkan-zig-generator");
    const vk_generate_cmd = b.addRunArtifact(vk_gen);

    if (maybe_override_registry) |override_registry| {
        vk_generate_cmd.addFileArg(.{ .cwd_relative = override_registry });
    } else {
        vk_generate_cmd.addFileArg(registry);
    }

    const vulkan_zig = b.addModule("vulkan_zig", .{ .root_source_file = vk_generate_cmd.addOutputFileArg("vk.zig") });
    gui_exe.root_module.addImport("vulkan", vulkan_zig);

    const gui_run_cmd = b.addRunArtifact(gui_exe);
    gui_run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        gui_run_cmd.addArgs(args);
    }

    const gui_run_step = b.step("run-gui", "Run the gui testbed app");
    gui_run_step.dependOn(&gui_run_cmd.step);

    // Base library
    // const lib = b.addStaticLibrary(.{
    //     .name = "base",
    //     .root_source_file = b.path("src/base.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // b.installArtifact(lib);

    // const lib_unit_tests = b.addTest(.{
    //     .root_source_file = b.path("src/base.zig"),
    //     .target = target,
    //     .optimize = optimize,
    //     .test_runner = b.path("src/test_runner.zig"),
    // });

    // const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_lib_unit_tests.step);
}
