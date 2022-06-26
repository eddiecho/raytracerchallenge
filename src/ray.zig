const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const SquareMatrix = @import("matrix.zig").SquareMatrix;

const TransformMatrix = SquareMatrix(4);

pub const Ray = struct {
  origin: Tuple,
  direction: Tuple,

  const Self = @This();

  pub fn new(origin: Tuple, direction: Tuple) Self {
    return Self {
      .origin = origin,
      .direction = direction,
    };
  }

  pub fn position(self: *const Self, t: f32) Tuple {
    return self.origin.add(&self.direction.scale(t));
  }

  pub fn scale(self: *const Self, x: f32, y: f32, z: f32) Self {
    const scale_matrix = TransformMatrix.scaling(x, y, z).invert() catch TransformMatrix.identity();
    return Self {
      .origin = scale_matrix.mult_vec(&self.origin),
      .direction = scale_matrix.mult_vec(&self.direction),
    };
  }

  pub fn translate(self: *const Self, x: f32, y: f32, z: f32) Self {
    const translate_matrix = TransformMatrix.translation(x, y, z).invert() catch TransformMatrix.identity();
    return Self {
      .origin = translate_matrix.mult_vec(&self.origin),
      .direction = self.direction,
    };
  }
};

const expect = std.testing.expect;

test "ray position" {
  const p = Tuple.point(2, 3, 4);
  const v = Tuple.vector(1, 0, 0);
  const r = Ray.new(p, v);

  const p1 = r.position(0);
  const p2 = r.position(1);
  const p3 = r.position(-1);
  const p4 = r.position(2.5);

  try expect(p1.eql(&Tuple.point(2, 3, 4)));
  try expect(p2.eql(&Tuple.point(3, 3, 4)));
  try expect(p3.eql(&Tuple.point(1, 3, 4)));
  try expect(p4.eql(&Tuple.point(4.5, 3, 4)));
}
