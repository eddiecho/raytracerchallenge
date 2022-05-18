const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;

pub const Color = struct {
  _data: Tuple,

  pub fn default() Color {
    return Color {
      ._data = Tuple.vector(0, 0, 0),
    };
  }

  pub fn new(re: f32, gr: f32, bl: f32) Color {
    return Color {
      ._data = Tuple.vector(re, gr, bl),
    };
  }

  pub fn add(self: *const Color, other: *const Color) Color {
    return Color {
      ._data = self._data.add(other._data),
    };
  }

  pub fn sub(self: *const Color, other: *const Color) Color {
    return Color {
      ._data = self._data.sub(other._data),
    };
  }

  pub fn scale(self: *const Color, scalar: f32) Color {
    return Color {
      ._data = self._data.scale(scalar),
    };
  }

  pub fn mult(self: *const Color, other: *const Color) Color {
    return Color {
      ._data = self._data.mult(other._data),
    };
  }

  pub fn r(self: *const Color) f32 {
    return self._data.x;
  }

  pub fn g(self: *const Color) f32 {
    return self._data.y;
  }

  pub fn b(self: *const Color) f32 {
    return self._data.z;
  }

  pub fn to_string(self: *const Color, allocator: std.mem.Allocator) []const u8 {
    var str = std.fmt.allocPrint(
      allocator,
      "{}, {}, {}",
      .{self.r(), self.g(), self.b()}
    ) catch "err, err, err";

    return str;
  }
};
