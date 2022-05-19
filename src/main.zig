const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const Color = @import("color.zig").Color;
const Canvas = @import("canvas.zig").Canvas;

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};

  const c1 = Color.new(1.5, 0, 0);
  const c2 = Color.new(0, 0.5, 0);
  const c3 = Color.new(-0.5, 0, 1.0);
  std.debug.print("{s}\n", .{c3.to_string(gpa.allocator())});

  const pic = try Canvas.new(gpa.allocator(), 5, 3);
  pic.set(0, 0, c1);
  pic.set(2, 1, c2);
  pic.set(4, 2, c3);
  std.debug.print("{any}", .{pic.data});
  _ = try pic.writeToPpm();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
