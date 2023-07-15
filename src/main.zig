const std = @import("std");
const a = @import("array.zig");
const crystal = @import("crystal.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const MyIntArray = a.MyArray(u8);
    var my_array = try MyIntArray.init(&allocator, 1024 * 1024);
    defer my_array.deinit(&allocator);

    my_array.random();
    my_array.sort();

    const chosen_elem = my_array.get_random();

    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_linear(chosen_elem) });
    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_binary(chosen_elem) });

    var breaks = [_]bool{ false, false, false, false, false, false, false, false, false, false, false, false, true, true, true };
    std.debug.print("Break found at {any}\n", .{crystal.crystal(&breaks)});
}

test {
    @import("std").testing.refAllDecls(@This());
}
