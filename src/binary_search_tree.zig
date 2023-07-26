const std = @import("std");
const q = @import("queue.zig");

pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        root: ?*Node,
        allocator: *std.mem.Allocator,

        pub const Node = struct {
            value: T,
            parent: ?*Node,
            left: ?*Node,
            right: ?*Node,

            pub fn init(allocator: *std.mem.Allocator, value: T) !*Node {
                var node = try allocator.create(Node);
                node.* = .{
                    .value = value,
                    .parent = null,
                    .left = null,
                    .right = null,
                };
                return node;
            }

            pub fn debug(self: *Node) void {
                std.debug.print("0x{x} <- ({} @ 0x{x}) ↑ 0x{x} -> 0x{x}\n", .{ @ptrToInt(self.left), self.value, @ptrToInt(self), @ptrToInt(self.parent), @ptrToInt(self.right) });
            }
        };

        pub fn deinit(self: *BinarySearchTree(T)) !void {
            var iter = try BreadthFirstSearch.init(self, self.allocator);
            defer iter.deinit();
            while (try iter.next()) |node| {
                self.allocator.destroy(node);
            }
        }

        const NodeList = std.ArrayList(T);

        // Pre Order Traversal.
        fn pre_walk(current: ?*Node, path: *NodeList) !*NodeList {
            // base case
            const c = current orelse return path;
            // pre
            try path.append(c.value);
            // recurse
            if (c.left) |left| {
                _ = try pre_walk(left, path);
            }
            if (c.right) |right| {
                _ = try pre_walk(right, path);
            }
            // post
            return path;
        }

        pub fn pre_order_traverse(self: *BinarySearchTree(T)) !*NodeList {
            var path = NodeList.init(self.allocator.*);
            return try pre_walk(self.root, &path);
        }

        fn order_walk(current: ?*Node, path: *NodeList) !*NodeList {
            // base case
            const c = current orelse return path;
            // pre

            // recurse
            if (c.left) |left| {
                _ = try order_walk(left, path);
            }
            try path.append(c.value);
            if (c.right) |right| {
                _ = try order_walk(right, path);
            }
            // post
            return path;
        }

        pub fn in_order_traverse(self: *BinarySearchTree(T)) !*NodeList {
            var path = NodeList.init(self.allocator.*);
            return try order_walk(self.root, &path);
        }

        fn post_walk(current: ?*Node, path: *NodeList) !*NodeList {
            // base case
            const c = current orelse return path;
            // pre

            // recurse
            if (c.left) |left| {
                _ = try post_walk(left, path);
            }
            if (c.right) |right| {
                _ = try post_walk(right, path);
            }
            try path.append(c.value);
            // post
            return path;
        }

        pub fn post_order_traverse(self: *BinarySearchTree(T)) !*NodeList {
            var path = NodeList.init(self.allocator.*);
            return try post_walk(self.root, &path);
        }

        pub const BreadthFirstSearch = struct {
            queue: q.Queue(?*Node),
            allocator: *std.mem.Allocator,

            pub fn init(tree: *BinarySearchTree(T), allocator: *std.mem.Allocator) !BreadthFirstSearch {
                var queue = q.Queue(?*Node).init(allocator);
                var root = tree.root;
                try queue.enqueue(root);
                return BreadthFirstSearch{ .queue = queue, .allocator = allocator };
            }

            pub fn deinit(self: *BreadthFirstSearch) void {
                self.queue.deinit();
            }

            pub fn next(self: *BreadthFirstSearch) !?*Node {
                var opt = self.queue.dequeue();
                var c1 = opt orelse return null;
                var current = c1 orelse return null;
                if (current.left) |l| {
                    try self.queue.enqueue(l);
                }
                if (current.right) |r| {
                    try self.queue.enqueue(r);
                }
                return current;
            }
        };

        pub const PostOrderSearch = struct {
            stack: std.ArrayList(?*Node),
            allocator: *std.mem.Allocator,

            pub fn init(tree: *BinarySearchTree(T), allocator: *std.mem.Allocator) !PostOrderSearch {
                var stack = std.ArrayList(?*Node).init(allocator);
                var root = tree.root;
                try stack.append(root);
                return PostOrderSearch{ .stack = stack, .allocator = allocator };
            }

            pub fn deinit(self: *PostOrderSearch) void {
                self.stack.deinit();
            }

            pub fn next(self: *PostOrderSearch) !?*Node {
                var current = self.stack.pop();
                _ = current;
            }
        };
    };
}
test "can in order traverse" {
    const BST = BinarySearchTree(i32);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var bst = BST{ .root = try BST.Node.init(&allocator, 7), .allocator = &allocator };
    bst.root.?.left = try BST.Node.init(&allocator, 23);
    bst.root.?.right = try BST.Node.init(&allocator, 3);
    bst.root.?.left.?.left = try BST.Node.init(&allocator, 5);
    bst.root.?.left.?.right = try BST.Node.init(&allocator, 4);
    bst.root.?.right.?.left = try BST.Node.init(&allocator, 18);
    bst.root.?.right.?.right = try BST.Node.init(&allocator, 21);
    var path = try bst.in_order_traverse();
    std.debug.print("{}", .{path});
}

test "can post order traverse" {
    const BST = BinarySearchTree(i32);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var bst = BST{ .root = try BST.Node.init(&allocator, 7), .allocator = &allocator };
    bst.root.?.left = try BST.Node.init(&allocator, 23);
    bst.root.?.right = try BST.Node.init(&allocator, 3);
    bst.root.?.left.?.left = try BST.Node.init(&allocator, 5);
    bst.root.?.left.?.right = try BST.Node.init(&allocator, 4);
    bst.root.?.right.?.left = try BST.Node.init(&allocator, 18);
    bst.root.?.right.?.right = try BST.Node.init(&allocator, 21);
    var path = try bst.post_order_traverse();
    std.debug.print("{}", .{path});
}

test "can pre order traverse" {
    const BST = BinarySearchTree(i32);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    var bst = BST{ .root = try BST.Node.init(&allocator, 7), .allocator = &allocator };
    bst.root.?.left = try BST.Node.init(&allocator, 23);
    bst.root.?.right = try BST.Node.init(&allocator, 3);
    bst.root.?.left.?.left = try BST.Node.init(&allocator, 5);
    bst.root.?.left.?.right = try BST.Node.init(&allocator, 4);
    bst.root.?.right.?.left = try BST.Node.init(&allocator, 18);
    bst.root.?.right.?.right = try BST.Node.init(&allocator, 21);
    var path = try bst.pre_order_traverse();
    std.debug.print("{}", .{path});
}

test "can breadth first travers" {
    const BST = BinarySearchTree(i8);
    var allocator = std.testing.allocator;
    var bst = BST{ .root = try BST.Node.init(&allocator, 7), .allocator = &allocator };
    bst.root.?.left = try BST.Node.init(&allocator, 23);
    bst.root.?.right = try BST.Node.init(&allocator, 3);
    bst.root.?.left.?.left = try BST.Node.init(&allocator, 5);
    bst.root.?.left.?.right = try BST.Node.init(&allocator, 4);
    bst.root.?.right.?.left = try BST.Node.init(&allocator, 18);
    bst.root.?.right.?.right = try BST.Node.init(&allocator, 21);
    var iter = try BST.BreadthFirstSearch.init(&bst, &allocator);
    defer iter.deinit();
    
    std.debug.print("==================\n", .{});
    while (try iter.next()) |node| {
        node.debug();
    }

    try bst.deinit();
}
