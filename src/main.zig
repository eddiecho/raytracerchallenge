const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const Color = @import("color.zig").Color;
const Canvas = @import("canvas.zig").Canvas;
const SquareMatrix = @import("matrix.zig").SquareMatrix;

pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};

  // ch2_final(&gpa.allocator());
  try ch4_final(&gpa.allocator());
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

fn ch2_final(allocator: *std.mem.Allocator) !void {
  const velocity = Tuple.vector(1, 1.8, 0).normalize().scale(11.25);
  var proj = Projectile {
    .pos = Tuple.point(0, 1, 0),
    .v = velocity,
  };
  const g = Tuple.vector(0, -0.1, 0);
  const res = Tuple.vector(-0.01, 0, 0);

  const width: u32 = 900;
  const height: u32 = 550;
  var pic = try Canvas.new(allocator, width, height);
  const red = Color.new(1, 0, 0);

  while (proj.pos.x < width and proj.pos.y < height and proj.pos.y >= 0) : (proj = tick(proj, g, res)) {
    const x = @floatToInt(u32, @round(proj.pos.x));
    const y = height - @floatToInt(u32, @round(proj.pos.y));

    pic.set(x, y, red);
  }

  _ = try pic.writeToPpm();
}

const Matrix = SquareMatrix(4);
const sqrt = std.math.sqrt;
const pi = std.math.pi;

fn ch4_set(pic: *Canvas, point: Tuple, color: Color) void {
  pic.set(@floatToInt(u32, point.x), @floatToInt(u32, point.y), color);
}

fn ch4_final(allocator: *std.mem.Allocator) !void {
  const width: u32 = 500;
  const height: u32 = 500;
  var pic = try Canvas.new(allocator, width, height);
  const white = Color.new(1, 1, 1);

  const origin = Tuple.point(0, 0, 0);

  var points :[12]Tuple = undefined;

  points[11] = Matrix.translation(0, 200, 0)
               .mult_vec(&origin);
  points[2] = Matrix.translation(200, 0, 0)
              .mult_vec(&origin);
  points[5] = Matrix.translation(0, -200, 0)
              .mult_vec(&origin);
  points[8] = Matrix.translation(-200, 0, 0)
              .mult_vec(&origin);

  points[0] = Matrix.rotation_z(pi / 6.0).mult_vec(&points[11]);
  points[1] = Matrix.rotation_z(pi / 3.0).mult_vec(&points[11]);

  points[3] = Matrix.rotation_z(pi / 6.0).mult_vec(&points[2]);
  points[4] = Matrix.rotation_z(pi / 3.0).mult_vec(&points[2]);

  points[6] = Matrix.rotation_z(pi / 6.0).mult_vec(&points[5]);
  points[7] = Matrix.rotation_z(pi / 3.0).mult_vec(&points[5]);

  points[9] = Matrix.rotation_z(pi / 6.0).mult_vec(&points[8]);
  points[10] = Matrix.rotation_z(pi / 3.0).mult_vec(&points[8]);

  for (points) |point| {
    const fin = Matrix.translation(250, 250, 0).mult_vec(&point);
    ch4_set(&pic, fin, white);
  }

  _ = try pic.writeToPpm();
}
