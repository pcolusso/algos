const std = @import("std");
const a = @import("array.zig");
const crystal = @import("crystal.zig");
const ll = @import("ll.zig");
const q = @import("queue.zig");
const al = @import("arraylist.zig");
const maze = @import("maze.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const MyIntArray = a.MyArray(u8);
    var my_array = try MyIntArray.init(&allocator, 1024);
    defer my_array.deinit(&allocator);

    my_array.random();
    my_array.sort2();

    const chosen_elem = my_array.get_random();

    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_linear(chosen_elem) });
    std.debug.print("{d} is at index {any}\n", .{ chosen_elem, my_array.index_of_binary(chosen_elem) });

    const MyQueue = q.Queue(i8);
    var queue = MyQueue.init(&allocator);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    try queue.enqueue(3);
    try queue.enqueue(4);

    std.debug.print("Dequeued: {?}\n", .{queue.dequeue()});
    std.debug.print("Dequeued: {?}\n", .{queue.dequeue()});
    std.debug.print("Dequeued: {?}\n", .{queue.dequeue()});

    var arraylist = try al.ArrayList(i32).init(&allocator);
    defer arraylist.deinit();

    try arraylist.push(1);
    try arraylist.push(2);
    try arraylist.push(3);
    try arraylist.push(4);
    try arraylist.push(5);

    std.debug.print("Popped: {?}, {?}, {?}\n", .{ arraylist.pop(), arraylist.pop(), arraylist.pop() });
    std.debug.print("Popped: {?}, {?}, {?}\n", .{ arraylist.pop(), arraylist.pop(), arraylist.pop() });

    var m = try maze.Maze.init(&allocator);
    defer m.deinit();
    m.print();
    const res = try m.solve();
    for (res.items) |item| {
        std.debug.print("{},{}\n", .{ item.x, item.y });
    }
    res.deinit();
}

test {
    @import("std").testing.refAllDecls(@This());
    _ = @import("array.zig");
    _ = @import("ll.zig");
    _ = @import("crystal.zig");
    _ = @import("doublell.zig");
}
