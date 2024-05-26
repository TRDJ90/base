// TODO: remove once im more comfortable defining static dispatching in zig....

const std = @import("std");

// The trait we are trying to make implementations for.
const Writer = struct {
    // (1) ptr to an actual implementation
    // (2) ptr to function of actual implentation
    ptr: *anyopaque,
    writeAllFn: *const fn (ptr: *anyopaque, data: []const u8) anyerror!void,

    fn init(ptr: *anyopaque) Writer {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);

        const gen = struct {
            pub fn writeAll(pointer: *anyopaque, data: []const u8) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return ptr_info.Pointer.child.writeAll(self, data);
            }
        };

        return .{
            .ptr = ptr,
            .writeAllFn = gen.writeAll,
        };
    }
    // (3) The interface implementation that will call the actual implementation by redirection
    fn writeAll(self: Writer, data: []const u8) !void {
        // (4) Call the actual implementation
        return self.writeAllFn(self.ptr, data);
    }
};

// Concrete implement of the trait above
const File = struct {
    fd: std.os.fd_t,

    // anyopaque erases type information, see it as a void pointer
    fn writeAll(ptr: *anyopaque, data: []const u8) !void {
        // cast ptr to a specific implementation ptr and align it correctly in memory.
        const self: *File = @ptrCast(@alignCast(ptr));
        _ = try std.os.write(self.fd, data);
    }

    fn writer(self: *File) Writer {
        return Writer.init(self);
    }
};
