const std = @import("std");
const testing = std.testing;

pub const test_utils = @import("test_utils.zig");

test "Test base lib code" {
    testing.refAllDecls(@This());
}

test "test1" {
    try testing.expect(std.mem.eql(u8, "hello", "hello"));
}

test "test2" {
    try testing.expect(std.mem.eql(u8, "hello", "hello"));
}

test "test3" {
    try testing.expect(std.mem.eql(u8, "hello", "hello"));
}
