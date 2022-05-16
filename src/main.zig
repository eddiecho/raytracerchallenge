const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const color = @import("color.zig");
const Canvas = @import("canvas.zig").Canvas;

pub fn main() anyerror!void {
  const foo = Tuple.point(0.0, 0.0, 0.0);
  std.debug.print("{}\n", .{foo.x} );
  const red = color.Color.new(1, 0, 0);
  std.debug.print("{s}\n", .{red.to_string()});

  const pic = try Canvas.new(2,2);
  pic.set(1, 0, red);
  std.debug.print("{any}", .{pic.data});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
