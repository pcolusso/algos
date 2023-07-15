const std = @import("std");

fn MyArray(comptime T: type) type {
    return struct {
        contents: []T,
        length: usize,

        fn init(allocator: *std.mem.Allocator, size: usize) !MyArray(T) {
            return MyArray(T){
                .contents = try allocator.alloc(T, size),
                .length = size,
            };
        }

        fn deinit(self: *MyArray(T), allocator: *std.mem.Allocator) void {
            allocator.free(self.contents);
        }

        fn set(self: *MyArray(T), index: usize, value: T) void {
            self.contents[index] = value;
        }

        fn get(self: *MyArray(T), index: usize) T {
            return self.contents[index];
        }

        fn length(self: *MyArray(T)) usize {
            return self.length;
        }

        fn print(self: *MyArray(T)) void {
            std.debug.print("MyArray({s}) = [", .{@typeName(T)});
            for (self.contents) |value, index| {
                if (index != 0) {
                    std.debug.print(", ", .{});
                }
                std.debug.print("{d}", .{value});
            }
            std.debug.print("]\n", .{});
        }

        fn indexOf(self: *MyArray(T), value: T) ?usize {
            var idx: usize = 0;
            while (idx < self.length) {
                if (self.contents[idx] == value) {
                    return idx;
                }
                idx += 1;
            }
            return null;
        }
    };
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const MyIntArray = MyArray(i32);
    var my_array = try MyIntArray.init(&allocator, 10);
    defer my_array.deinit(&allocator);

    my_array.set(0, 1);
    my_array.set(3, 3);

    my_array.print();

    std.debug.print("3 is at index {any}\n", .{my_array.indexOf(3)});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
