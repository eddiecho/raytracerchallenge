const std = @import("std");

const EPSILON = std.math.floatEps(f32);

pub const Tuple = struct {
  x: f32,
  y: f32,
  z: f32,
  w: f32,

  pub fn point(x: f32, y: f32, z: f32) Tuple {
    return Tuple {
      .x = x,
      .y = y,
      .z = z,
      .w = 1.0,
    };
  }

  pub fn vector(x: f32, y: f32, z: f32) Tuple {
    return Tuple {
      .x = x,
      .y = y,
      .z = z,
      .w = 0.0,
    };
  }

  pub fn equals(self: *const Tuple, other: *const Tuple) bool {
    return (std.math.approxEqAbs(f32, self.x, other.x, EPSILON))
     and (std.math.approxEqAbs(f32, self.y, other.y, EPSILON))
     and (std.math.approxEqAbs(f32, self.z, other.z, EPSILON))
     and (std.math.approxEqAbs(f32, self.w, other.w, EPSILON));
  }
};

test "tuple equals" {
  const one = Tuple.point(1.0, -1.0, 1.0);
  const two = Tuple.point(1.0, -1.0, 1.0000001);

  try std.testing.expect(one.equals(&two));
}


