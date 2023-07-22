// We're in some classical Paul programming here folks.

const std = @import("std");

const Cell = enum {
    wall,
    space,
    start,
    end,

    pub fn to_string(self: Cell) []const u8 {
        return switch (self) {
            .wall => "#",
            .space => " ",
            .start => "s",
            .end => "e",
        };
    }
};

const Point = struct { x: i8, y: i8 };

const simple_maze: [30]Cell = [_]Cell{
    Cell.wall, Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.end,   Cell.wall,
    Cell.wall, Cell.space, Cell.space, Cell.space, Cell.space, Cell.space, Cell.space, Cell.space, Cell.space, Cell.wall,
    Cell.wall, Cell.start, Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,  Cell.wall,
};

const Error = error{ OOB, NoStart, NoEnd };

pub const Maze = struct {
    width: usize,
    height: usize,
    contents: []Cell,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) !Maze {
        const width = 10;
        const height = 3;
        const cells = try allocator.alloc(Cell, width * height);
        std.mem.copy(Cell, cells, &simple_maze);

        return Maze{ .width = width, .height = height, .contents = cells, .allocator = allocator };
    }

    pub fn deinit(self: *Maze) void {
        self.allocator.free(self.contents);
    }

    fn in_bounds(self: *const Maze, point: Point) bool {
        return index_into(self, point) < self.width * self.height;
    }

    inline fn index_into(self: *const Maze, point: Point) usize {
        return @intCast(usize, (point.y * @intCast(i8, self.width) + point.x));
    }

    pub fn get(self: *const Maze, point: Point) ?Cell {
        if (!self.in_bounds(point)) return null;
        return self.contents[self.index_into(point)];
    }

    fn u_get(self: *const Maze, point: Point) Cell {
        return self.contents[self.index_into(point)];
    }

    pub fn set(self: *Maze, point: Point, cell: Cell) !void {
        if (!self.in_bounds(point)) return Error.OOB;
        self.contents[index_into(point)] = cell;
    }

    pub fn print(self: *const Maze) void {
        var y: i8 = 0;
        while (y < self.height) : (y += 1) {
            var x: i8 = 0;
            while (x < self.width) : (x += 1) {
                const cell = self.u_get(Point{ .x = x, .y = y });
                std.debug.print("{s}", .{cell.to_string()});
            }
            std.debug.print("\n", .{});
        }
    }

    const List = std.ArrayList(Point);
    const dir = [4][2]i8{
        [_]i8{ -1, 0 },
        [_]i8{ 1, 0 },
        [_]i8{ 0, -1 },
        [_]i8{ 0, 1 },
    };

    fn contains(list: *const List, pos: Point) bool {
        for (list.items) |item| {
            if (item.x == pos.x and item.y == pos.y) return true;
        }
        return false;
    }

    fn find_start(self: *const Maze) !Point {
        var x: i8 = 0;
        while (x < self.width) : (x += 1) {
            var y: i8 = 0;
            while (y < self.height) : (y += 1) {
                const cell = self.u_get(Point{ .x = x, .y = y });
                if (cell == Cell.start) return Point{ .x = x, .y = y };
            }
        }
        return Error.NoStart;
    }

    fn find_end(self: *const Maze) !Point {
        var x: i8 = 0;
        while (x < self.width) : (x += 1) {
            var y: i8 = 0;
            while (y < self.height) : (y += 1) {
                const cell = self.u_get(Point{ .x = x, .y = y });
                if (cell == Cell.end) return Point{ .x = x, .y = y };
            }
        }
        return Error.NoEnd;
    }

    fn walk(self: *const Maze, pos: Point, seen: *List, path: *List) !bool {
        std.debug.print("Inspecting {d}, {d} -> ", .{ pos.x, pos.y });
        // If OOB, go back
        if (!self.in_bounds(pos)) return false;
        const cell = self.u_get(pos);
        std.debug.print("It's a {any}\n", .{cell});
        // It's a wall, go back
        if (cell == Cell.wall) return false;
        // If we've seein it, go back
        if (contains(seen, pos)) return false;
        // Ayy, we've made it.
        if (cell == Cell.end) {
            try path.*.append(pos);
            return true;
        }

        // pre
        try path.*.append(pos);
        try seen.*.append(pos);

        var i: usize = 0;
        while (i < 4) : (i += 1) {
            const d = dir[i];
            const current = Point{ .x = pos.x + d[0], .y = pos.y + d[1] };
            if (try self.walk(current, seen, path)) {
                return true;
            }
        }

        _ = path.*.pop();

        return false;
    }

    pub fn solve(self: *Maze) !List {
        var seen = List.init(self.allocator.*);
        defer seen.deinit();
        var path = List.init(self.allocator.*);
        const start = try self.find_start();
        _ = try self.find_end();

        _ = try self.walk(start, &seen, &path);

        return path;
    }
};
