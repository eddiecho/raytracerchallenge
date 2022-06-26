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

  pub fn transform(self: *const Self, orig_transform: *const TransformMatrix) Self {
    const transform_matrix = orig_transform.invert() catch TransformMatrix.identity();

    return Self {
      .origin = transform_matrix.mult_vec(&self.origin),
      .direction = transform_matrix.mult_vec(&self.direction),
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
