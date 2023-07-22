const std = @import("std");

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct { value: T, next: ?*Node = null, prev: ?*Node = null };

        head: ?*Node = null,
        tail: ?*Node = null,
        length: usize = 0,

        pub fn init(allocator: *std.mem.allocator) DoublyLinkedList(T) {
            return DoublyLinkedList(T){ .allocator = allocator };
        }

        pub fn deinit(self: *DoublyLinkedList(T)) void {
            var iter = self.iterator();
            while (iter.next()) |node| {
                self.allocator.destroy(node);
            }
        }

        pub const Iterator = struct {
            list: *DoublyLinkedList(T),
            cursor: ?*Node,

            pub fn init(list: *DoublyLinkedList(T), start: *Node) Iterator {
                return Iterator{ .list = list, .cursor = start };
            }

            pub fn next(self: *Iterator) ?*Node {
                var current = self.cursor;
                if (current) |c| {
                    self.cursor = c.next;
                }
                return current;
            }

            pub fn prev(self: *Iterator) ?*Node {
                var current = self.cursor;
                if (current) |c| {
                    self.cursor = c.prev;
                }
                return current;
            }
        };

        pub fn iter_forwards(self: *DoublyLinkedList(T)) Iterator {
            return Iterator.init(self, self.head);
        }

        pub fn iter_backwards(self: *DoublyLinkedList(T)) Iterator {
            return Iterator.init(self, self.tail);
        }

        pub fn prepend(self: *DoublyLinkedList(T), value: T) !void {
            var node = try self.allocator.create(Node);
            node.*.value = value;

            self.length += 1;

            if (self.head == null) {
                self.head = node;
                self.tail = node;
                return;
            }

            node.*.next = self.head;
            self.head.*.prev = node;
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
            var node = try self.allocator.create(Node);
            node.*.value = value;
            self.length += 1;

            if (self.tail != null) {
                self.head = node;
                self.tail = node;
                return;
            }

            node.prev = self.tail;
            self.tail.next = node.prev;
            self.tail = node;
        }
    };
}
