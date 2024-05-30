const std = @import("std");
const vk = @import("vulkan");
const c = @import("c.zig");
const logging = @import("logging.zig");
const Logger = logging.Logger;
const ConsoleLogger = logging.ConsoleLogger;
const LogLevel = logging.LogLevel;

const app_name = "gui testbed";

pub fn main() !void {
    const consoleLogger = ConsoleLogger.init();
    const logger = Logger{ .console = consoleLogger };

    try logger.log(LogLevel.none, "\n");
    try logger.log(LogLevel.info, "Starting app");

    if (c.glfwInit() != c.GLFW_TRUE) return error.GlfwInitFailed;
    defer c.glfwTerminate();

    if (c.glfwVulkanSupported() != c.GLFW_TRUE) {
        try logger.log(LogLevel.err, "Couldn't start glfw with vulkan");
        return error.NoVulkan;
    }

    const extent = vk.Extent2D{ .width = 800, .height = 600 };

    try logger.log(LogLevel.info, "Create Window");
    c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);
    const window = c.glfwCreateWindow(
        @intCast(extent.width),
        @intCast(extent.height),
        app_name,
        null,
        null,
    ) orelse return error.WindowInitFailed;
    defer c.glfwDestroyWindow(window);

    try logger.log(LogLevel.info, "start application loop");
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        var w: c_int = undefined;
        var h: c_int = undefined;
        c.glfwGetFramebufferSize(window, &w, &h);

        // Don't present or resize swapchain while the window is minimized
        if (w == 0 or h == 0) {
            c.glfwPollEvents();
            continue;
        }

        c.glfwPollEvents();
    }

    try logger.log(LogLevel.info, "shutdown application");
}
