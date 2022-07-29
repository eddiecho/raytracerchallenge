const std = @import("std");
const ch6 = @import("chapters/ch6.zig");

const World = @import("shapes/world.zig").World;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try ch6.final(gpa.allocator());

    const world = try World.default(gpa.allocator());
    _ = world;
}

test "all" {
    std.testing.refAllDecls(@This());
}
