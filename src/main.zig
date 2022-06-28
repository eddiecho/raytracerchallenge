const std = @import("std");

const ch5 = @import("endings/ch5.zig");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try ch5.final(gpa.allocator());
}

test "all" {
    std.testing.refAllDecls(@This());
}
