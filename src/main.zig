const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const color = @import("color.zig");
const Canvas = @import("canvas.zig").Canvas;

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};

  const foo = Tuple.point(0.0, 0.0, 0.0);
  std.debug.print("{}\n", .{foo.x} );
  const red = color.Color.new(1, 0, 0);
  std.debug.print("{s}\n", .{red.to_string(gpa.allocator())});

  const pic = try Canvas.new(gpa.allocator(), 2,2);
  pic.set(1, 0, red);
  std.debug.print("{any}", .{pic.data});
  _ = try pic.writeToPpm();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
