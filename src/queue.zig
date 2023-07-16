const std = @import("std");

pub fn Queue(comptime T: type) type {
    
    return struct {
        pub const Node = struct { value: T, next: ?*Node = null };

        head: ?*Node = null,
        tail: ?*Node = null,
        length: usize,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) Queue(T) {
            return Queue(T){ .allocator = allocator, .head = null, .tail = null, .length = 0 };
        }

        pub fn deinit(self: Queue(T)) void {
            var iter = self.iterator();
            while (iter.next()) |node| {
                self.allocator.destroy(node);
            }
        }

        // Getting what's next is constant time.
        pub fn dequeue(self: *Queue(T)) ?T {
            if (self.head) |h| {
                self.head = h.next;
                self.length = self.length - 1;
                const value = h.value;
                self.allocator.destroy(h);
                return value;
            }
            return null;
        }

        pub fn peek(self: *Queue(T)) ?T {
            if (self.head) |h| {
                return h.value;
            }
            return null;
        }

        // Adding is also constant time.
        pub fn enqueue(self: *Queue(T), elem: T) !void {
            var node = try self.allocator.create(Node);
            node.*.value = elem;
            node.*.next = null;

            if (self.tail == null) {
                self.tail = node;
                self.head = node;
            }

            if (self.tail) |t| {
                t.next = node;
            } else {
                self.head = node;
            }

            self.tail = node;
            self.length = self.length + 1;
        }

        pub const Iterator = struct {
            queue: *const Queue(T),
            cursor: ?*Node,

            pub fn init(queue: *const Queue(T)) Iterator {
                return Iterator{ .queue = queue, .cursor = queue.head orelse null };
            }

            pub fn next(self: *Iterator) ?*Node {
                if (self.queue.length == 0) return null; // ?
                var current = self.cursor;
                if (current) |c| {
                    self.cursor = c.next;
                }
                return current;
            }
        };

        pub fn iterator(self: *const Queue(T)) Iterator {
            return Iterator.init(self);
        }
    };
}
