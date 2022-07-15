const std = @import("std");
const ch6 = @import("chapters/ch6.zig");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try ch6.final(gpa.allocator());
}

test "all" {
    std.testing.refAllDecls(@This());
}
