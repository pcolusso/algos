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

test {
    // Use MyArray of i32 for these tests.
    var allocator = std.testing.allocator;

    // Test 1: Empty Array
    var arr = try MyArray(i32).init(&allocator, 10);
    defer arr.deinit(&allocator);
    try std.testing.expect(try arr.index_of_binary(10) == null);

    // Test 2: One element (needle present)
    const pos: usize = 0;
    arr.set(pos, 10);
    try std.testing.expect(try arr.index_of_binary(10) == pos);

    // Test 3: One element (needle not present)
    try std.testing.expect(try arr.index_of_binary(20) == null);

    // Test 4: Multiple elements (needle present)
    const pos1: usize = 1;
    const pos2: usize = 2;
    const pos3: usize = 3;
    arr.set(pos1, 20);
    arr.set(pos2, 30);
    arr.set(pos3, 40);
    try std.testing.expect(try arr.index_of_binary(30) == pos2);

    // Test 5: Multiple elements (needle not present)
    try std.testing.expect(try arr.index_of_binary(50) == null);
}
