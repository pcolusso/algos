const std = @import("std");

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            value: T,
            next: ?*Node = null,
            prev: ?*Node = null,

            pub fn print(self: *const Node) void {
                std.debug.print("Node:\n0x{x} <- ({} @ 0x{x} ) -> 0x{x}\n", .{ @ptrToInt(self.prev), self.value, @ptrToInt(self), @ptrToInt(self.next) });
            }

            pub fn init(allocator: *std.mem.Allocator, value: T) !*Node {
                var node = try allocator.create(Node);
                node.* = Node{ .value = value, .prev = null, .next = null };
                return node;
            }
        };

        head: ?*Node = null,
        tail: ?*Node = null,
        length: usize = 0,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) DoublyLinkedList(T) {
            return DoublyLinkedList(T){ .allocator = allocator };
        }

        pub fn deinit(self: *DoublyLinkedList(T)) void {
            var iter = self.iter_forwards();
            while (iter.next()) |node| {
                std.debug.print("Destroying 0x{x}", .{@ptrToInt(node)});
                self.allocator.destroy(node);
            }
        }

        pub const Iterator = struct {
            cursor: ?*Node,

            pub fn init(list: *DoublyLinkedList(T)) Iterator {
                std.debug.print("\n============NEW ITER==========\n", .{});
                return Iterator{ .cursor = list.head };
            }

            pub fn next(self: *Iterator) ?*Node {
                std.debug.print("Iterating... Current is @ 0x{x}\n", .{@ptrToInt(self.cursor)});
                const current = self.cursor;
                if (current) |c| {
                    self.cursor = c.next;
                    std.debug.print("Confirmed that 0x{x} is valid!\n", .{@ptrToInt(c)});
                    c.print();
                }
                return current;
            }
        };

        pub fn iter_forwards(self: *DoublyLinkedList(T)) Iterator {
            return Iterator.init(self);
        }

        pub fn prepend(self: *DoublyLinkedList(T), value: T) !void {
            var node = try Node.init(self.allocator, value);

            self.length += 1;

            if (self.head == null) {
                self.head = node;
                self.tail = node;
                return;
            }

            node.*.next = self.head;

            if (self.head) |h| {
                h.*.prev = node;
            }
            self.head = node;
        }

        const Error = error{ OutOfBounds, NotFound };

        pub fn find(self: *DoublyLinkedList(T), item: T) ?*Node {
            const iter = self.iter_forwards();
            while (iter.next()) |node| {
                if (node.value == item) {
                    return node;
                }
            }
            return null;
        }

        pub fn remove(self: *DoublyLinkedList(T), item: T) !void {
            const elem = self.find(item);

            if (elem == null) {
                return Error.NotFound;
            }

            self.length -= 1;

            if (self.length == 0) {
                self.head = null;
                self.tail = null;
                return;
            }

            if (elem.prev != null) {
                elem.prev = elem.next;
            }

            if (elem.next != null) {
                elem.next = elem.prev;
            }

            if (self.head == elem) {
                self.head = elem.next;
            }

            if (self.tail == elem) {
                self.tail = elem.prev;
            }

            self.allocator.destroy(elem);
        }

        pub fn insert_at(self: *DoublyLinkedList(T), at: usize, value: T) !void {
            if (at > self.length) {
                return Error.OutOfBounds;
            } else if (at == self.length) {
                self.append(value);
                return;
            } else if (at == 0) {
                self.prepend(value);
                return;
            }

            var index = 0;
            var current = self.head;

            while (current != null) : (index += 1) {
                if (index == at) {
                    var node = try self.allocator.create(Node);
                    node.*.value = value;
                    node.*.next = current;
                    node.*.prev = current.prev;
                    current.prev = node;
                    self.length += 1;

                    if (node.prev != null) {
                        node.prev.next = current; // SHould this be node?
                    }
                }
                current = current.next;
            }
        }

        pub fn append(self: *DoublyLinkedList(T), value: T) !void {
            var node = try Node.init(self.allocator, value);

            if (self.length == 0) {
                self.head = node;
                self.tail = node;
                self.length += 1;
            } else {
                if (self.tail) |t| {
                    t.next = node;
                    node.prev = t;
                }
                self.tail = node;
                self.length += 1;
            }
        }

        pub fn debug(self: *DoublyLinkedList(T)) void {
            std.debug.print("head: {?}, tail: {?}, length: {?}\n", .{ self.head, self.tail, self.length });
        }
    };
}

test "can append to a list" {
    var allocator = std.testing.allocator;
    var list = DoublyLinkedList(i32).init(&allocator);
    defer list.deinit();

    try list.append(1);
    try list.append(2);
    try list.append(3);

    try std.testing.expectEqual(list.length, 3);

    var i: i32 = 0;
    var iter = list.iter_forwards();
    while (iter.next()) |node| {
        i += 1;
        try std.testing.expectEqual(node.value, i);
    }
}

test "can prepend to a list" {
    var allocator = std.testing.allocator;
    var list = DoublyLinkedList(u32).init(&allocator);
    defer list.deinit();

    try list.prepend(1);
    try list.prepend(2);
    try list.prepend(3);

    try std.testing.expectEqual(list.length, 3);
}
test "can insert_at" {}
