const std = @import("std");
const a = @import("array.zig");
const crystal = @import("crystal.zig");
const ll = @import("ll.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const MyIntArray = a.MyArray(u8);
    var my_array = try MyIntArray.init(&allocator, 1024);
    defer my_array.deinit(&allocator);

    my_array.random();
    my_array.sort();

    const chosen_elem = my_array.get_random();

    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_linear(chosen_elem) });
    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_binary(chosen_elem) });

    var breaks = [_]bool{ false, false, false, false, false, false, false, false, false, false, false, false, true, true, true };
    std.debug.print("Break found at {any}\n", .{crystal.crystal(&breaks)});

    const MyLL = ll.LinkedList(i32);
    var list = MyLL.init(&allocator);
    defer list.deinit();

    try list.prepend(3);
    try list.prepend(1);
    try list.insert_after(0, 2);
    try list.insert_after(2, 4);
    try list.remove_at(3);
    try list.insert_end(12);
    list.print();
}

test {
    @import("std").testing.refAllDecls(@This());
}
