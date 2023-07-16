const std = @import("std");
const default_capacity = 3;

pub fn ArrayList(comptime T: type) type {
    return struct {
        length: usize,
        capacity: usize,
        contents: []T,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) !ArrayList(T) {
            return ArrayList(T) {
                .allocator = allocator,
                .length = 0,
                .capacity = default_capacity,
                .contents = try allocator.alloc(T, default_capacity)
            };
        }

        pub fn deinit(self: *ArrayList(T)) void {
            // Erase the contents.
            self.allocator.free(self.contents);
        }

        fn grow(self: *ArrayList(T)) !void {
            // Create a new buffer, with a larger size
            const new_capacity = self.capacity * 2;
            var new_buffer = try self.allocator.alloc(T, new_capacity);

            // Copy the data from the old, into the new
            std.mem.copy(T, new_buffer, self.contents);

            // Update the capacity
            std.debug.print("Growing from {} to {}\n", .{self.capacity, new_capacity});
            self.capacity = new_capacity;

            // Delete the old buffer.
            const old_buffer = self.contents;
            self.contents = new_buffer;
            self.allocator.free(old_buffer);
            
        }

        pub fn push(self: *ArrayList(T), value: T) !void {
            const new_index = self.length + 1;
            if (self.capacity <= new_index) {
                try self.grow();
            }

            self.contents[new_index] = value;
            self.length = self.length + 1;
        }

        pub fn pop(self: *ArrayList(T)) !void {
            const value = self.contents[self.length];
            if (self.length > 0) self.length = self.length - 1;
            return value;
        }

        pub fn get_at(self: *ArrayList(T), index: usize) ?T {
            if (index > self.length) return null;
            return self.contents[index];
        }
    };
}
