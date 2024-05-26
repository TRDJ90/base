// Based on
// 0): https://gist.github.com/nurpax/4afcb6e4ef3f03f0d282f7c462005f12
// 1): https://gist.github.com/karlseguin/c6bea5b35e4e8d26af6f81c22cb5d76b

const std = @import("std");
const builtin = @import("builtin");

const BORDER = "=" ** 80;

const Status = enum {
    pass,
    fail,
    skip,
    text,
};

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const alloc = gpa.allocator();
    // Fail first?
    const fail_first = true;

    const printer = Printer.init();
    printer.fmt("\r\x1b[0k", .{});

    var pass: usize = 0;
    var fail: usize = 0;
    var skip: usize = 0;
    var leak: usize = 0;

    for (builtin.test_functions) |t| {
        //var iter = std.mem.split(u8, t.name, ".");

        //std.debug.print("{any}\n", .{t});

        //std.debug.print("file: {s}\n", .{iter.next().?});
        //std.debug.print("test: {s}\n", .{iter.next().?});
        //std.debug.print("test name: {s}\n", .{iter.next().?});

        //std.debug.print("name: {s}\n\n", .{t.name});
        // std.debug.print("{?}", .{t});

        std.testing.allocator_instance = .{};
        var status = Status.pass;

        const test_name = t.name[5..];
        printer.fmt("Testing {s}:", .{test_name});
        const result = t.func();

        if (std.testing.allocator_instance.deinit() == .leak) {
            leak += 1;
            printer.status(.fail, "\n{s}\n\"{s}\" - Memory Leak\n{s}\n", .{ BORDER, test_name, BORDER });
        }

        if (result) |_| {
            pass += 1;
        } else |err| {
            switch (err) {
                error.SkipZigTest => {
                    skip += 1;
                    status = .skip;
                },
                else => {
                    status = .fail;
                    fail += 1;
                    printer.status(.fail, "\n{s}\n\"{s}\" - {s}\n{s}\n", .{ BORDER, test_name, @errorName(err), BORDER });
                    if (@errorReturnTrace()) |trace| {
                        std.debug.dumpStackTrace(trace.*);
                    }
                    if (fail_first) {
                        break;
                    }
                },
            }
        }

        printer.status(status, "[{s}]\n", .{@tagName(status)});
    }

    const total_tests = pass + fail;
    const status: Status = if (fail == 0) .pass else .fail;
    printer.status(status, "\n{d} of {d} test{s} passed\n", .{ pass, total_tests, if (total_tests != 1) "s" else "" });
    if (skip > 0) {
        printer.status(.skip, "{d} test{s} skipped\n", .{ skip, if (skip != 1) "s" else "" });
    }
    if (leak > 0) {
        printer.status(.fail, "{d} test{s} leaked\n", .{ leak, if (leak != 1) "s" else "" });
    }
    std.process.exit(if (fail == 0) 0 else 1);
}

const Printer = struct {
    out: std.fs.File.Writer,

    fn init() Printer {
        return .{
            .out = std.io.getStdErr().writer(),
        };
    }

    fn fmt(self: @This(), comptime format: []const u8, args: anytype) void {
        std.fmt.format(self.out, format, args) catch unreachable;
    }

    fn status(self: @This(), s: Status, comptime format: []const u8, args: anytype) void {
        const color = switch (s) {
            .pass => "\x1b[32m",
            .fail => "\x1b[31m",
            .skip => "\x1b[33m",
            else => "",
        };
        const out = self.out;
        out.writeAll(color) catch @panic("writeAll failed!");
        std.fmt.format(out, format, args) catch @panic("std.fmt.format failed!");
        self.fmt("\x1b[0m", .{});
    }
};
