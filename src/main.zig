const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;

pub fn main() anyerror!void {
  const foo = Tuple.point(0.0, 0.0, 0.0);
  std.debug.print("{}", .{foo.x} );
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
