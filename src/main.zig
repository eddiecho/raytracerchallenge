const std = @import("std");

const ch5 = @import("chapters/ch5.zig");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try ch5.final(gpa.allocator());
}

test "all" {
    std.testing.refAllDecls(@This());
}
