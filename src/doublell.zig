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
                self.allocator.destroy(node);
            }
        }

        const Direction = enum { Forwards, Backwards };

        fn iterate(comptime direction: Direction) type {
            return struct {
                cursor: ?*Node,

                pub fn next(self: *@This()) ?*Node {
                    var current = self.cursor;
                    if (current) |c| {
                        var next_node = if (direction == Direction.Forwards) c.next else c.prev;
                        self.cursor = next_node;
                    }
                    return current;
                }
            };
        }

        pub const ForwardIterator = iterate(.Forwards);
        pub const BackwardsIterator = iterate(.Backwards);

        pub fn iter_forwards(self: *DoublyLinkedList(T)) ForwardIterator {
            return ForwardIterator{ .cursor = self.head };
        }

        pub fn iter_backwards(self: *DoublyLinkedList(T)) BackwardsIterator {
            return BackwardsIterator{ .cursor = self.tail };
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

    var i: u32 = 0;
    var iter = list.iter_backwards();
    while (iter.next()) |node| {
        i += 1;
        try std.testing.expectEqual(node.value, i);
    }
}
test "can insert_at" {}
