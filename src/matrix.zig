const std = @import("std");
const assert = std.debug.assert;

const utils = @import("utils.zig");
const Tuple = @import("tuple.zig").Tuple;

const MatrixError = error {
  Uninvertible,
};

pub fn SquareMatrix(comptime len: usize) type {
  return struct {
    const Self = @This();
    const size = len * len;

    data: [size]f32 = [_]f32{0.0} ** (size),

    pub fn init(data: [size]f32) Self {
      return Self {
        .data = data,
      };
    }

    pub fn identity() Self {
      var ret = Self{};
      var i: usize = 0;
      while (i < len) : (i += 1) {
        ret.set(i,i, 1);
      }

      return ret;
    }

    pub fn set(self: *Self, x: usize, y: usize, val: f32) void {
      const idx = (len * x) + y;
      assert(idx < size);
      self.data[idx] = val;
    }

    pub fn get(self: *const Self, x: usize, y: usize) f32 {
      const idx = (len * x) + y;
      assert(idx < size);
      return self.data[idx];
    }

    pub fn eql(self: *const Self, other: *const Self) bool {
      var i: usize = 0;
      while (i < len) : (i += 1) {
        if (!utils.f32_equals(self.data[i], other.data[i])) return false;
      }

      return true;
    }

    pub fn mult(self: *const Self, other: *const Self) Self {
      var data: [size]f32 = undefined;

      var i: usize = 0;
      while (i < len) : (i += 1) {

        var j: usize = 0;
        while (j < len) : (j += 1) {

          var sum: f32 = 0;

          var a: usize = 0;
          while (a < len) : (a += 1) {
            sum += self.get(i, a) * other.get(a, j);
          }

          data[(len * i) + j] = sum;
        }
      }

      return Self {
        .data = data,
      };
    }

    pub fn mult_vec(self: *const Self, vector: *const Tuple) Tuple {
      assert(len == 4);

      const x = self.get(0,0) * vector.x +
                self.get(0,1) * vector.y +
                self.get(0,2) * vector.z +
                self.get(0,3) * vector.w;

      const y = self.get(1,0) * vector.x +
                self.get(1,1) * vector.y +
                self.get(1,2) * vector.z +
                self.get(1,3) * vector.w;

      const z = self.get(2,0) * vector.x +
                self.get(2,1) * vector.y +
                self.get(2,2) * vector.z +
                self.get(2,3) * vector.w;

      const w = self.get(3,0) * vector.x +
                self.get(3,1) * vector.y +
                self.get(3,2) * vector.z +
                self.get(3,3) * vector.w;

      return Tuple.init(x, y, z, w);
    }

    pub fn transpose(self: *const Self) Self {
      var ret = Self{};

      var i: usize = 0;
      while (i < len) : (i += 1) {

        var j: usize = 0;
        while (j < len) : (j += 1) {

          ret.set(j, i, self.get(i, j));
        }
      }

      return ret;
    }

    fn submatrix(self: *const Self, x: usize, y: usize) SquareMatrix(len - 1) {
      const Matrix1 = SquareMatrix(len - 1);
      var ret = Matrix1{};

      var i: usize = 0;
      var x_idx: usize = 0;
      while (i < len) : (i += 1) {

        if (i == x) continue;

        var j: usize = 0;
        var y_idx: usize = 0;
        while (j < len) : (j += 1) {

          if (j == y) continue;

          ret.set(x_idx, y_idx, self.get(i, j));

          y_idx += 1;
        }

        x_idx += 1;
      }

      return ret;
    }

    fn determinant(self: *const Self) f32 {
      if (len == 2) {
        return (self.get(0,0) * self.get(1,1)) - (self.get(0,1) * self.get(1,0));
      }

      var ret: f32 = 0.0;
      var sign: f32 = 1.0;

      var i: usize = 0;
      while (i < len) : ({i += 1; sign *= -1;}) {
        const sub = self.submatrix(0, i);
        const sub_det = sub.determinant();
        ret += (sign * sub_det * self.get(0, i));
      }

      return ret;
    }

    // inversion by Cramer's rule
    // TODO - try inversion by Gaussian elimination, better stability and algorithmic complexity
    pub fn invert(self: *const Self) MatrixError!Self {
      const det = self.determinant();
      if (det == 0) {
        return MatrixError.Uninvertible;
      }

      var ret = Self{};

      var i: usize = 0;
      while (i < len) : (i += 1) {

        var j: usize = 0;
        while (j < len) : (j += 1) {

          const minor = self.submatrix(i, j).determinant();
          const sign: f32 = if ((i + j) % 2 == 0) 1 else -1;

          ret.set(j, i, sign * minor / det);
        }
      }

      return ret;
    }

  };
}

test "2x2" {
  const Matrix2 = SquareMatrix(2);
  var a = Matrix2{};
  a.data[3] = 5.0;
  a.set(0,1, 2.0);
  try std.testing.expectApproxEqAbs(a.get(1,1), 5.0, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(0,0), 0.0, 0.00001);

  const b_data = .{
    -3, 5,
    1, -2
  };
  const b = Matrix2.init(b_data);
  try std.testing.expectApproxEqAbs(b.get(0,0), -3, 0.00001);
  try std.testing.expectApproxEqAbs(b.get(0,1), 5, 0.00001);
  try std.testing.expectApproxEqAbs(b.get(1,0), 1, 0.00001);
  try std.testing.expectApproxEqAbs(b.get(1,1), -2, 0.00001);
}

test "3x3" {
  const Matrix3 = SquareMatrix(3);
  const data = .{
    -3, 5, 0,
    1, -2, -7,
    0, 1, 1,
  };
  const a = Matrix3.init(data);
  try std.testing.expectApproxEqAbs(a.get(0,0), -3, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(1,1), -2, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(2,2), 1, 0.00001);
}

test "4x4" {
  const Matrix4 = SquareMatrix(4);
  const data = .{
    1, 2, 3, 4,
    5.5, 6.5, 7.5, 8.5,
    9, 10, 11, 12,
    13.5, 14.5, 15.5, 16.5
  };
  const a = Matrix4.init(data);

  try std.testing.expectApproxEqAbs(a.get(0,0), 1, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(0,3), 4, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(1,0), 5.5, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(1,2), 7.5, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(2,2), 11, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(3,0), 13.5, 0.00001);
  try std.testing.expectApproxEqAbs(a.get(3,2), 15.5, 0.00001);
}

test "eql" {
  const Matrix4 = SquareMatrix(4);
  const data = .{
    1, 2, 3, 4,
    1, 2, 3, 4,
    1, 2, 3, 4,
    1, 2, 3, 4,
  };

  const a = Matrix4.init(data);
  const b = Matrix4.init(data);
  const c = Matrix4{};
  try std.testing.expect(a.eql(&b));
  try std.testing.expect(!a.eql(&c));
  try std.testing.expect(!c.eql(&a));
}

test "matrix-matrix mult" {
  const Matrix4 = SquareMatrix(4);

  const a_data = .{
    1, 2, 3, 4,
    2, 3, 4, 5,
    3, 4, 5, 6,
    4, 5, 6, 7,
  };

  const b_data = .{
    -2, 1, 2, 3,
    3, 2, 1, -1,
    4, 3, 6, 5,
    1, 2, 7, 8,
  };

  const c_data = .{
    20, 22, 50, 48,
    44, 54, 114, 108,
    40, 58, 110, 102,
    16, 26, 46, 42,
  };

  const a = Matrix4.init(a_data);
  const b = Matrix4.init(b_data);
  const c = Matrix4.init(c_data);

  const ab = a.mult(&b);
  try std.testing.expect(ab.eql(&c));
}

test "matrix-vector mult" {
  const Matrix4 = SquareMatrix(4);

  const data = .{
    1, 2, 3, 4,
    2, 4, 4, 2,
    8, 6, 4, 1,
    0, 0, 0, 1,
  };
  const a = Matrix4.init(data);
  const b = Tuple.init(1, 2, 3, 1);
  const c = Tuple.init(18, 24, 33, 1);
  const ab = a.mult_vec(&b);

  try std.testing.expect(ab.eql(&c));
}

test "identity matrix" {
  const Matrix4 = SquareMatrix(4);

  const data = .{
    0, 1, 2, 4,
    1, 2, 4, 8,
    2, 4, 8, 16,
    4, 8, 16, 32,
  };
  const a = Matrix4.init(data);
  const i = Matrix4.identity();
  const ai = a.mult(&i);
  try std.testing.expect(a.eql(&ai));

  const b = Tuple.init(1, 2, 3, 4);
  const bi = i.mult_vec(&b);
  try std.testing.expect(b.eql(&bi));
}

test "transpose" {
  const Matrix4 = SquareMatrix(4);

  const a_data = .{
    0, 9, 3, 0,
    9, 8, 0, 8,
    1, 8, 5, 3,
    0, 0, 5, 8,
  };
  const a = Matrix4.init(a_data);

  const t_data = .{
    0, 9, 1, 0,
    9, 8, 8, 0,
    3, 0, 5, 5,
    0, 8, 3, 8,
  };
  const a_t = Matrix4.init(t_data);

  try std.testing.expect(a_t.eql(&a.transpose()));

  const i = Matrix4.identity();
  try std.testing.expect(i.transpose().eql(&Matrix4.identity()));
}

test "submatrix" {
  const Matrix4 = SquareMatrix(4);
  const Matrix3 = SquareMatrix(3);
  const Matrix2 = SquareMatrix(2);

  const data_4 = .{
    -6, 1, 1, 6,
    -8, 5, 8, 6,
    -1, 0, 8, 2,
    -7, 1, -1, 1,
  };
  const data_3 = .{
    -6, 1, 6,
    -8, 8, 6,
    -7, -1, 1,
  };
  const data_2 = .{
    -6, 6,
    -7, 1,
  };

  const m4 = Matrix4.init(data_4);
  const m3 = Matrix3.init(data_3);
  const m2 = Matrix2.init(data_2);

  try std.testing.expect(m3.eql(&m4.submatrix(2, 1)));
  try std.testing.expect(m2.eql(&m3.submatrix(1, 1)));
}

test "determinant" {
  const Matrix4 = SquareMatrix(4);
  const Matrix3 = SquareMatrix(3);
  const Matrix2 = SquareMatrix(2);

  const data_2 = .{
    1, 5,
    -3, 2,
  };
  const data_3 = .{
    1, 2, 6,
    -5, 8, -4,
    2, 6, 4,
  };
  const data_4 = .{
    -2, -8, 3, 5,
    -3, 1, 7, 3,
    1, 2, -9, 6,
    -6, 7, 7, -9,
  };

  const m2 = Matrix2.init(data_2);
  const m3 = Matrix3.init(data_3);
  const m4 = Matrix4.init(data_4);

  try std.testing.expectApproxEqAbs(m2.determinant(), 17, 0.00001);
  try std.testing.expectApproxEqAbs(m3.determinant(), -196, 0.00001);
  try std.testing.expectApproxEqAbs(m4.determinant(), -4071, 0.00001);
}

test "invert" {
  const Matrix4 = SquareMatrix(4);
  const data = .{
    8, -5, 9, 2,
    7, 5, 6, 1,
    -6, 0, 9, 6,
    -3, 0, -9, -4,
  };

  const i_data = .{
    -0.15385, -0.15385, -0.28205, -0.53846,
    -0.07692, 0.12308, 0.02564, 0.03077,
    0.35897, 0.35897, 0.43590, 0.92308,
    -0.69231, -0.69231, -0.76923, -1.92308,
  };

  const a = Matrix4.init(data);
  const a_invert = try a.invert();
  const a_i = Matrix4.init(i_data);

  try std.testing.expect(a_invert.eql(&a_i));
}

test "inverse multiplication" {
  const Matrix4 = SquareMatrix(4);

  const a_data = .{
    3, -9, 7, 3,
    3, -8, 2, -9,
    -4, 4, 4, 1,
    6, 5, -1, 1,
  };
  const b_data = .{
    8, 2, 2, 2,
    3, -1, 7, 0,
    7, 0, 5, 4,
    6, -2, 0, 5,
  };

  const a = Matrix4.init(a_data);
  const b = Matrix4.init(b_data);
  const b_i = try b.invert();
  const c = a.mult(&b);
  const c_b_i = c.mult(&b_i);

  try std.testing.expect(a.eql(&c_b_i));
}

