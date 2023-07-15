const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            elem: T,
            next: ?*Node = null,

            pub fn get_last(self: *Node) ?*Node {
                var current = self.next;
                while (true) {
                    const next = current.next;
                    if (next == null) {
                        return current;
                    }
                }
            }

            pub fn print(self: *Node) void {
                std.debug.print("Am {any} holding ({any}) next -> {any}", .{ &self, self.elem, self.next });
            }
        };

        head: ?*Node = null,

        pub fn empty(self: *LinkedList(T)) bool {
            return self.head == null;
        }

        pub fn prepend(self: *LinkedList(T), elem: T) void {
            var node = Node{ .elem = elem, .next = self.head };
            self.head = &node;
        }

        pub fn print(self: *LinkedList(T)) void {
            var current = self.head;
            while (current) |node_ptr| {
                node_ptr.print();
                current = if (node_ptr.next) |next_ptr| next_ptr else null;
            }
        }
    };
}
