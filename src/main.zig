const std = @import("std");
const RndGen = std.rand.DefaultPrng;

pub fn MyArray(comptime T: type) type {
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

        // Helper to make some sample arrays.
        fn zeroes(self: *MyArray(T)) void {
            for (self.contents) |_, index| {
                self.contents[index] = 0;
            }
        }

        // Helper to make some sample arrays.
        fn random(self: *MyArray(T)) void {
            var rnd = RndGen.init(0);
            for (self.contents) |_, index| {
                self.contents[index] = rnd.random().int(T);
            }
        }

        fn cmp(context: void, a: T, b: T) bool {
            return std.sort.asc(T)(context, a, b);
        }

        // TODO, until we actually get to implementing some sorts
        fn sort(self: *MyArray(T)) void {
            std.sort.sort(T, self.contents, {}, cmp);
        }

        fn set(self: *MyArray(T), index: usize, value: T) void {
            self.contents[index] = value;
        }

        fn get(self: *MyArray(T), index: usize) T {
            return self.contents[index];
        }

        fn get_random(self: *MyArray(T)) T {
            var rnd = RndGen.init(0);
            const chosen = @mod(rnd.random().int(usize), self.length);
            return self.contents[chosen];
        }

        fn length(self: *MyArray(T)) usize {
            return self.length;
        }

        // Helper to debug print
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

        // It's a linear search!
        fn index_of_linear(self: *MyArray(T), needle: T) !?usize {
            var idx: usize = 0;
            var timer = try std.time.Timer.start();
            defer std.debug.print("linear search took {d} \n", .{timer.read()});
            while (idx < self.length) {
                if (self.contents[idx] == needle) {
                    return idx;
                }
                idx += 1;
            }
            return null;
        }

        fn index_of_binary(self: MyArray(T), needle: T) !?usize {
            var high = self.length - 1; // !!!
            var low: usize = 0;
            var timer = try std.time.Timer.start();
            defer std.debug.print("Binary search took {d} \n", .{timer.read()});

            while (low < high) {
                var midpoint = low + ((high - low) / 2);
                var value = self.contents[midpoint];

                if (value == needle) {
                    return midpoint;
                } else if (value > needle) {
                    high = midpoint;
                } else {
                    low = midpoint + 1;
                }
            }

            return null;
        }
    };
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const MyIntArray = MyArray(i32);
    var my_array = try MyIntArray.init(&allocator, 1_000_000);
    defer my_array.deinit(&allocator);

    my_array.random();
    my_array.sort();

    // const chosen_elem = my_array.get_random();
    const chosen_elem = 69;

    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_linear(chosen_elem) });
    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_binary(chosen_elem) });
}
