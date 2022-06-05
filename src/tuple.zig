const std = @import("std");
const assert = std.debug.assert;
const sqrt = std.math.sqrt;

const SquareMatrix = @import("matrix.zig").SquareMatrix;
const utils = @import("utils.zig");

const Transformer = SquareMatrix(4);

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
      .w = 1,
    };
  }

  pub fn vector(x: f32, y: f32, z: f32) Tuple {
    return Tuple {
      .x = x,
      .y = y,
      .z = z,
      .w = 0,
    };
  }

  pub fn init(x: f32, y: f32, z: f32, w: f32) Tuple {
    return Tuple {
      .x = x,
      .y = y,
      .z = z,
      .w = w,
    };
  }

  pub fn zero() Tuple {
    return Tuple {
      .x = 0,
      .y = 0,
      .z = 0,
      .w = 0,
    };
  }

  pub fn eql(self: *const Tuple, other: *const Tuple) bool {
    const dim = self.dim_equals(other);
    return (dim and (self.is_vector() == other.is_vector()));
  }

  fn dim_equals(self: *const Tuple, other: *const Tuple) bool {
    const x = utils.f32_equals(self.x, other.x);
    const y = utils.f32_equals(self.y, other.y);
    const z = utils.f32_equals(self.z, other.z);

    return (x and y and z);
  }

  pub fn add(self: *const Tuple, other: *const Tuple) Tuple {
    const self_vec = self.is_vector();
    const other_vec = other.is_vector();
    // #1. both vector
    // #2. one of vec and point
    assert((self_vec and other_vec) or (utils.xor(self_vec, other_vec)));

    return Tuple.init(
      self.x + other.x,
      self.y + other.y,
      self.z + other.z,
      self.w + other.w
    );
  }

  pub fn sub(self: *const Tuple, other: *const Tuple) Tuple {
    const self_vec = self.is_vector();
    const other_vec = other.is_vector();
    // #1. both point
    // #2. both vector
    // #3, point and vec (order matters)
    assert((!utils.xor(self_vec, other_vec)) or (!self_vec and other_vec));

    return Tuple.init(
      self.x - other.x,
      self.y - other.y,
      self.z - other.z,
      self.w - other.w
    );
  }

  pub fn is_point(self: *const Tuple) bool {
    return utils.f32_equals(self.w, 1.0);
  }

  pub fn is_vector(self: *const Tuple) bool {
    return utils.f32_equals(self.w, 0.0);
  }

  // return a new one or inplace replacement?
  pub fn neg(self: *const Tuple) Tuple {
    return Tuple.init(
      -self.x,
      -self.y,
      -self.z,
      -self.w,
    );
  }

  pub fn scale(self: *const Tuple, scalar: f32) Tuple {
    return Tuple.init(
      self.x * scalar,
      self.y * scalar,
      self.z * scalar,
      self.w * scalar,
    );
  }

  pub fn mag(self: *const Tuple) f32 {
    assert(self.is_vector());
    const sum = (self.x * self.x) + (self.y * self.y) + (self.z * self.z);
    return sqrt(sum);
  }

  pub fn normalize(self: *const Tuple) Tuple {
    assert(self.is_vector());
    const len = self.mag();
    return self.scale(1.0 / len);
  }

  pub fn dot(self: *const Tuple, other: *const Tuple) f32 {
    return ((self.x * other.x) +
      (self.y * other.y) +
      (self.z * other.z) +
      (self.w * other.w));
  }

  pub fn cross(self: *const Tuple, other: *const Tuple) Tuple {
    assert(self.is_vector() and other.is_vector());

    return Tuple.vector(
      (self.y * other.z) - (self.z * other.y),
      (self.z * other.x) - (self.x * other.z),
      (self.x * other.y) - (self.y * other.x)
    );
  }

  pub fn mult(self: *const Tuple, other: *const Tuple) Tuple {
    return Tuple.init(
      self.x * other.x,
      self.y * other.y,
      self.z * other.z,
      self.w * other.w,
    );
  }

  pub fn transform(self: *const Tuple, mat: *const Transformer) Tuple {
    return mat.mult_vec(self);
  }
};

const expect = std.testing.expect;

test "tuple equals" {
  const one = Tuple.point(1.0, -1.0, 1.0);
  const two = Tuple.point(1.0, -1.0, 1.0000001);

  try expect(one.eql(&two));
}

test "tuple add" {
  const a = Tuple.point(3, -2, 5);
  const b = Tuple.vector(-2, 3, 1);

  const c = a.add(&b);

  try expect(c.eql(&Tuple.point(1, 1, 6)));
}

test "tuple sub two points" {
  const a = Tuple.point(3, 2, 1);
  const b = Tuple.point(5, 6, 7);

  const c = a.sub(&b);
  try expect(c.eql(&Tuple.vector(-2, -4, -6)));
}

test "tuple sub vector from point" {
  const p = Tuple.point(3, 2, 1);
  const v = Tuple.vector(5, 6, 7);

  const pv = p.sub(&v);
  try expect(pv.eql(&Tuple.point(-2, -4, -6)));
}

test "tuple sub two vectors" {
  const a = Tuple.vector(3, 2, 1);
  const b = Tuple.vector(5, 6, 7);

  const c = a.sub(&b);
  try expect(c.eql(&Tuple.vector(-2, -4, -6)));
}

test "tuple negate" {
  const a = Tuple.init(1, -2, 3, -4);
  const c = a.neg();

  try expect(c.eql(&Tuple.init(-1, 2, -3, 4)));
}

test "tuple scale" {
  const a = Tuple.init(1, -2, 3, -4);
  const ac = a.scale(3.5);
  try expect(ac.eql(&Tuple.init(3.5, -7, 10.5, -14)));

  const b = Tuple.init(1, -2, 3, -4);
  const bc = b.scale(1.0/2.0);
  try expect(bc.eql(&Tuple.init(0.5, -1, 1.5, -2)));
}

test "tuple mag" {
  const a = Tuple.vector(1, 0, 0);
  try expect(utils.f32_equals(a.mag(), 1.0));

  const b = Tuple.vector(0, 1, 0);
  try expect(utils.f32_equals(b.mag(), 1.0));

  const c = Tuple.vector(0, 0, 1);
  try expect(utils.f32_equals(c.mag(), 1.0));

  const d = Tuple.vector(1, 2, 3);
  try expect(utils.f32_equals(d.mag(), sqrt(14.0)));

  const e = Tuple.vector(-1, -2, -3);
  try expect(utils.f32_equals(e.mag(), sqrt(14.0)));
}

test "tuple normalize" {
  const a = Tuple.vector(4, 0, 0);
  const an = a.normalize();
  try expect(an.eql(&Tuple.vector(1, 0, 0)));

  const b = Tuple.vector(1, 2, 3);
  const bn = b.normalize();
  try expect(bn.eql(&Tuple.vector(0.26726, 0.53453, 0.80178)));
  try expect(utils.f32_equals(bn.mag(), 1.0));
}

test "tuple dot" {
  const a = Tuple.vector(1, 2, 3);
  const b = Tuple.vector(2, 3, 4);
  try expect(utils.f32_equals(a.dot(&b), 20));
}

test "tuple cross" {
  const a = Tuple.vector(1, 2, 3);
  const b = Tuple.vector(2, 3, 4);
  const ab = a.cross(&b);
  const ba = b.cross(&a);

  try expect(ab.eql(&Tuple.vector(-1, 2, -1)));
  try expect(ba.eql(&Tuple.vector(1, -2, 1)));
}

