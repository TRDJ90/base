const std = @import("std");
const logging = @import("logging.zig");
const Logger = logging.Logger;
const ConsoleLogger = logging.ConsoleLogger;
const LogLevel = logging.LogLevel;

pub fn main() !void {
    const console_output = ConsoleLogger.init();
    const logger = Logger{ .console = console_output };
    try logger.log(LogLevel.info, "Hello world info");
    try logger.log(LogLevel.warning, "Hello world warning");
    try logger.log(LogLevel.debug, "Hello world debug");
    try logger.log(LogLevel.err, "Hello world error");
}
