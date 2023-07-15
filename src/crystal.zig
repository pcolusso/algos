const std = @import("std");

pub fn crystal(breaks: []bool) !?usize {
    var index: usize = 0;

    while (index < breaks.len) {
        const jump_amount = @intToFloat(f32, index) + @sqrt(@intToFloat(f32, breaks.len));
        const jump: usize = @floatToInt(usize, jump_amount);
        index = index + jump;

        std.debug.print("Moving to new index: {d}\n", .{index});

        if (index >= breaks.len or breaks[index] == true) {
            std.debug.print("We've broken a ball, walking back to {d}\n", .{index});
            index = index - jump;
            // We've broken, walk back to previous index
            while (index < breaks.len) {
                if (breaks[index] == true) {
                    return index;
                }
                index = index + 1;
            }
        }
    }

    return null;
}

test {
    var only_one = [_]bool{true};
    try std.testing.expect(try crystal(&only_one) == @as(usize, 0));

    only_one = [_]bool{false};
    try std.testing.expect(try crystal(&only_one) == null);

    var two = [_]bool{ false, true };
    try std.testing.expect(try crystal(&two) == @as(usize, 1));

    var at_the_very_end = [_]bool{ false, false, false, false, false, true };
    try std.testing.expect(try crystal(&at_the_very_end) == @as(usize, 5));
}
