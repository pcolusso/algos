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
