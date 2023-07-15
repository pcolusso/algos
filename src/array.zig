const std = @import("std");
const RndGen = std.rand.DefaultPrng;

pub fn MyArray(comptime T: type) type {
    return struct {
        contents: []T,
        length: usize,

        pub fn init(allocator: *std.mem.Allocator, size: usize) !MyArray(T) {
            return MyArray(T){
                .contents = try allocator.alloc(T, size),
                .length = size,
            };
        }

        pub fn deinit(self: *MyArray(T), allocator: *std.mem.Allocator) void {
            allocator.free(self.contents);
        }

        // Helper to make some sample arrays.
        pub fn zeroes(self: *MyArray(T)) void {
            for (self.contents) |_, index| {
                self.contents[index] = 0;
            }
        }

        // Helper to make some sample arrays.
        pub fn random(self: *MyArray(T)) void {
            var rnd = RndGen.init(0);
            for (self.contents) |_, index| {
                self.contents[index] = rnd.random().int(T);
            }
        }

        fn cmp(context: void, a: T, b: T) bool {
            return std.sort.asc(T)(context, a, b);
        }

        // TODO, until we actually get to implementing some sorts
        pub fn sort(self: *MyArray(T)) void {
            std.sort.sort(T, self.contents, {}, cmp);
        }

        pub fn set(self: *MyArray(T), index: usize, value: T) void {
            self.contents[index] = value;
        }

        pub fn get(self: *MyArray(T), index: usize) T {
            return self.contents[index];
        }

        pub fn get_random(self: *MyArray(T)) T {
            var rnd = RndGen.init(0);
            const chosen = @mod(rnd.random().int(usize), self.length);
            return self.contents[chosen];
        }

        pub fn length(self: *MyArray(T)) usize {
            return self.length;
        }

        // Helper to debug print
        pub fn print(self: *MyArray(T)) void {
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
        pub fn index_of_linear(self: *MyArray(T), needle: T) !?usize {
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

        // It's a binary search!
        pub fn index_of_binary(self: MyArray(T), needle: T) !?usize {
            var high = self.length;
            var low: usize = 0;
            var timer = try std.time.Timer.start();
            defer std.debug.print("Binary search took {d} \n", .{timer.read()});

            while (low < high) {
                var midpoint = low + (high - low) / 2; // its low PLUS (high - low) / 2  
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

test {
    // Use MyArray of i32 for these tests.
    var allocator = std.testing.allocator;

    // Test 1: Empty Array
    var arr = try MyArray(i32).init(&allocator, 10);
    defer arr.deinit(&allocator);
    arr.zeroes();
    try std.testing.expect(try arr.index_of_binary(10) == null);

    arr.set(0, 1);
    arr.set(1, 2);
    arr.set(2, 3);
    arr.set(3, 4);
    arr.set(4, 5);
    arr.set(5, 6);
    arr.set(6, 7);
    arr.set(7, 8);
    arr.set(8, 9);
    arr.set(9, 10);
    arr.sort();

    try std.testing.expect(try arr.index_of_binary(5) != null );
    try std.testing.expect(try arr.index_of_binary(1) != null );
    try std.testing.expect(try arr.index_of_binary(7) != null );
    try std.testing.expect(try arr.index_of_binary(10) != null );
    try std.testing.expect(try arr.index_of_binary(0) == null );
}
