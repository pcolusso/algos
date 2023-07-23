const std = @import("std");

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

        const NodeList = std.ArrayList(T);

        // Pre Order Traversal.
        fn walk(current: ?*Node, path: *NodeList) !*NodeList {
            // base case
            const c = current orelse return path;
            c.debug();
            // pre
            try path.append(c.value);
            // recurse
            _ = try walk(c.left, path);
            _ = try walk(c.right, path);
            // post
            return path;
        }

        pub fn in_order_traverse(self: *BinarySearchTree(T)) !*NodeList {
            var path = NodeList.init(self.allocator.*);
            return try walk(self.root, &path);
        }
    };
}

test "can in order traverse" {
    const BST = BinarySearchTree(i32);
    var allocator = std.testing.allocator;
    var bst = BST{ .root = try BST.Node.init(&allocator, 7), .allocator = &allocator };
    bst.root.?.left = try BST.Node.init(&allocator, 23);
    bst.root.?.right = try BST.Node.init(&allocator, 3);
    bst.root.?.left.?.left = try BST.Node.init(&allocator, 5);
    bst.root.?.left.?.right = try BST.Node.init(&allocator, 4);
    bst.root.?.right.?.left = try BST.Node.init(&allocator, 18);
    bst.root.?.right.?.right = try BST.Node.init(&allocator, 21);
    var path = try bst.in_order_traverse();
    path.deinit();
}
