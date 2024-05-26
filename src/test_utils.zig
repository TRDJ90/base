const std = @import("std");

pub fn test_log_message(message: []const u8) !void {
    std.debug.print("\n└─> Message: {s}", .{message});
}

test "test de test" {
    try std.testing.expectEqual(8, 8);
}
