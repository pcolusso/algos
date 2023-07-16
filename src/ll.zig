const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            value: T,
            next: ?*Node = null,

            pub fn print(self: *Node) void {
                std.debug.print("Am {any} next -> {?}\n", .{ &self, &self.next });
            }
        };

        head: ?*Node,
        allocator: *std.mem.Allocator,

        pub fn init(allocator: *std.mem.Allocator) LinkedList(T) {
            return LinkedList(T){ .allocator = allocator, .head = null };
        }

        pub fn deinit(self: *LinkedList(T)) void {
            var iter = self.iterator();
            while (iter.next()) |node| {
                self.allocator.destroy(node);
            }
        }

        pub fn empty(self: *LinkedList(T)) bool {
            return self.head == null;
        }

        pub fn prepend(self: *LinkedList(T), elem: T) !void {
            var node = try self.allocator.create(Node);
            node.*.value = elem;

            node.*.next = self.head;
            self.head = node;
        }

        pub fn length(self: *LinkedList(T)) usize {
            var iter = self.iterator();
            var count: usize = 0;
            while (iter.next()) |node| {
                _ = node;
                count += 1;
            }
            return count;
        }

        pub fn get_at(self: *LinkedList(T), index: usize) ?*Node {
            var iter = self.iterator();
            var count: usize = 0;
            while (iter.next()) |node| {
                if (count == index) {
                    return node;
                }
                count += 1;
            }
            return null;
        }

        const Error = error{OutOfBounds};

        pub fn insert_after(self: *LinkedList(T), index: usize, value: T) !void {
            var node = try self.allocator.create(Node);
            node.*.value = value;

            var prev = self.get_at(index);

            if (prev) |p| {
                var next = p.next;
                p.next = node;
                node.next = next;
            } else {
                self.allocator.destroy(node);

                return Error.OutOfBounds;
            }
        }

        pub fn insert_end(self: *LinkedList(T), value: T) !void {
            const l = self.length();
            const index = if (l == 0) 0 else l - 1;

            try self.insert_after(index, value);
        }

        pub fn remove_at(self: *LinkedList(T), index: usize) !void {
            var node = self.get_at(index);
            // If we're at the beginning, we need to set head to node.next
            // If we're in the middle, we'll need to make prev point to node.next
            if (node) |n| {
                if (index == 0) {
                    self.head = n.next;
                } else if (self.get_at(index - 1)) |prev| {
                    prev.next = n.next;
                }
                self.allocator.destroy(n);
            } else {
                return Error.OutOfBounds;
            }
        }

        pub fn print(self: *LinkedList(T)) void {
            var iter = self.iterator();
            while (iter.next()) |node| {
                std.debug.print("Node: {any}\n", .{node.value});
            }
        }

        pub const Iterator = struct {
            list: *LinkedList(T),
            cursor: ?*Node,

            pub fn init(list: *LinkedList(T)) Iterator {
                return Iterator{ .list = list, .cursor = list.head orelse null };
            }

            pub fn next(self: *Iterator) ?*Node {
                var current = self.cursor;
                if (current) |c| {
                    self.cursor = c.next;
                }
                return current;
            }
        };

        pub fn iterator(self: *LinkedList(T)) Iterator {
            return Iterator.init(self);
        }
    };
}
