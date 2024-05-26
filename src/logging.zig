const std = @import("std");

pub const LogLevel = enum {
    info,
    debug,
    warning,
    err,
};

pub const Logger = union(enum) {
    console: ConsoleLogger,

    pub fn log(self: Logger, level: LogLevel, data: []const u8) !void {
        switch (self) {
            .console => |console| return console.log(level, data),
        }
    }
};

pub const ConsoleLogger = struct {
    const ansi_reset = "\x1b[0m";
    const ansi_red = "\x1b[31m";
    const ansi_green = "\x1b[32m";
    const ansi_yellow = "\x1b[33m";
    const ansi_blue = "\x1b[34m";

    out: std.fs.File.Writer,

    pub fn init() ConsoleLogger {
        return .{
            .out = std.io.getStdOut().writer(),
        };
    }

    fn log(self: ConsoleLogger, level: LogLevel, data: []const u8) !void {
        switch (level) {
            LogLevel.info => try self.out.print("{s}[info]  {s}{s}\n", .{ ansi_green, data, ansi_reset }),
            LogLevel.warning => try self.out.print("{s}[warn]  {s}{s}\n", .{ ansi_yellow, data, ansi_reset }),
            LogLevel.debug => try self.out.print("{s}[debug] {s}{s}\n", .{ ansi_blue, data, ansi_reset }),
            LogLevel.err => try self.out.print("{s}[error] {s}{s}\n", .{ ansi_red, data, ansi_reset }),
        }
    }
};
