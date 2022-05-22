const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const Color = @import("color.zig").Color;
const Canvas = @import("canvas.zig").Canvas;

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};

//  const c1 = Color.new(1.5, 0, 0);
//  const c2 = Color.new(0, 0.5, 0);
//  const c3 = Color.new(-0.5, 0, 1.0);

//  const pic = try Canvas.new(gpa.allocator(), 5, 3);
//  pic.set(0, 0, c1);
//  pic.set(2, 1, c2);
//  pic.set(4, 2, c3);
  // std.debug.print("{any}", .{pic.data});

  // end of chapter 2 test
  const velocity = Tuple.vector(1, 1.8, 0).normalize().scale(11.25);
  var proj = Projectile {
    .pos = Tuple.point(0, 1, 0),
    .v = velocity,
  };
  const g = Tuple.vector(0, -0.1, 0);
  const res = Tuple.vector(-0.01, 0, 0);

  const width: u32 = 900;
  const height: u32 = 550;
  const pic = try Canvas.new(gpa.allocator(), width, height);
  const red = Color.new(1, 0, 0);

  while (proj.pos.x < width and proj.pos.y < height and proj.pos.y >= 0) : (proj = tick(proj, g, res)) {
    const x = @floatToInt(u32, @round(proj.pos.x));
    const y = height - @floatToInt(u32, @round(proj.pos.y));

    pic.set(x, y, red);
  }

  _ = try pic.writeToPpm();
}

const Projectile = struct {
  pos: Tuple,
  v: Tuple,
};

fn tick(proj: Projectile, g: Tuple, res: Tuple) Projectile {
  const new_pos = proj.pos.add(&proj.v);
  const new_v = proj.v.add(&g).add(&res);

  const ret = Projectile {
    .pos = new_pos,
    .v = new_v,
  };

  return ret;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
