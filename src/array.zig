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

        // It's bubble sort!
        pub fn sort(self: *MyArray(T)) void {
            // An array is sorted provided that x[i] <= x[i+1] for all i.
            var outer: usize = 0;
            while (outer < self.length) {
                var inner: usize = 0;
                while (inner < self.length - 1 - outer) {
                    if (self.contents[inner] > self.contents[inner + 1]) {
                        const temp = self.contents[inner];
                        self.contents[inner] = self.contents[inner + 1];
                        self.contents[inner + 1] = temp;
                    }
                    inner = inner + 1;
                }
                outer = outer + 1;
            }
        }

        fn quicksort(arr: *[]T, low: i32, high: i32) void {
            // Recursion! So remember out base case, when low == high
            if (low >= high) {
                return;
            }

            const pivot_index = partition(arr, low, high);

            // We never want to be sorting with our pivot, notice how we go around it.
            quicksort(arr, low, pivot_index - 1);
            quicksort(arr, pivot_index + 1, high);
        }

        fn partition(arr: *[]T, low: i32, high: i32) i32 {
            const pivot = arr.*[@intCast(usize, high)]; // Not ideal, but simple for this impl
            var index = low - 1;
            // Walk from the low to the high, but not including.
            var i = low;
            while (i < high) : (i += 1) {
                if (arr.*[@intCast(usize, i)] <= pivot) {
                    index += 1; // We do this first so that on first run, we end up at 0.
                    // swapsies
                    const tmp = arr.*[@intCast(usize, i)];
                    arr.*[@intCast(usize, i)] = arr.*[@intCast(usize, index)];
                    arr.*[@intCast(usize, index)] = tmp;
                }
            }

            // We now need to move our pivot value into it's place
            index += 1;
            arr.*[@intCast(usize, high)] = arr.*[@intCast(usize, index)];
            arr.*[@intCast(usize, index)] = pivot;

            return index;
        }

        // It's QuickSort!
        pub fn sort2(self: *MyArray(T)) void {
            // Two functions, "partition" which chooses a pivot, and the actual recursive qs function.
            quicksort(&self.contents, 0, @intCast(i32, self.length) - 1);
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

test "can perform bubble sort" {
    var allocator = std.testing.allocator;
    var arr = try MyArray(i32).init(&allocator, 10);
    defer arr.deinit(&allocator);

    arr.set(0, 3);
    arr.set(1, 2);
    arr.set(2, 9);
    arr.set(3, 7);
    arr.set(4, 1);
    arr.set(5, 2);
    arr.set(6, 4);
    arr.set(7, 5);
    arr.set(8, 6);
    arr.set(9, 0);
    arr.sort();

    try std.testing.expectEqual(arr.get(0), 0);
    try std.testing.expectEqual(arr.get(1), 1);
    try std.testing.expectEqual(arr.get(2), 2);
}

test "can perform quicksort" {
    var allocator = std.testing.allocator;
    var arr = try MyArray(i32).init(&allocator, 10);
    defer arr.deinit(&allocator);

    arr.set(0, 3);
    arr.set(1, 2);
    arr.set(2, 9);
    arr.set(3, 7);
    arr.set(4, 1);
    arr.set(5, 2);
    arr.set(6, 4);
    arr.set(7, 5);
    arr.set(8, 6);
    arr.set(9, 0);
    arr.sort2();

    try std.testing.expectEqual(arr.get(0), 0);
    try std.testing.expectEqual(arr.get(1), 1);
    try std.testing.expectEqual(arr.get(2), 2);
}

test "can perform binary search" {
    var allocator = std.testing.allocator;
    var arr = try MyArray(i8).init(&allocator, 10);
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

    try std.testing.expect(try arr.index_of_binary(5) != null);
    try std.testing.expect(try arr.index_of_binary(1) != null);
    try std.testing.expect(try arr.index_of_binary(7) != null);
    try std.testing.expect(try arr.index_of_binary(10) != null);
    try std.testing.expect(try arr.index_of_binary(0) == null);
}
