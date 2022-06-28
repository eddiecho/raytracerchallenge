const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const utils = @import("../utils.zig");

pub const Color = struct {
    _data: Tuple,

    pub fn default() Color {
        return Color{
            ._data = Tuple.zero(),
        };
    }

    pub fn new(re: f32, gr: f32, bl: f32) Color {
        return Color{
            ._data = Tuple.init(re, gr, bl, 0),
        };
    }

    pub fn add(self: *const Color, other: *const Color) Color {
        return Color{
            ._data = self._data.elementwiseAdd(other._data),
        };
    }

    pub fn sub(self: *const Color, other: *const Color) Color {
        return Color{
            ._data = self._data.elementwiseSub(other._data),
        };
    }

    pub fn scale(self: *const Color, scalar: f32) Color {
        return Color{
            ._data = self._data.elementwiseScale(scalar),
        };
    }

    pub fn mult(self: *const Color, other: *const Color) Color {
        return Color{
            ._data = self._data.elementwiseMult(other._data),
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

    pub fn to32bit(self: *const Color) [3]u8 {
        return .{ utils.clamp(self.r()), utils.clamp(self.g()), utils.clamp(self.b()) };
    }

    pub fn toString(self: *const Color, allocator: std.mem.Allocator) []const u8 {
        var str = std.fmt.allocPrint(allocator, "{}, {}, {}", .{ self.r(), self.g(), self.b() }) catch "err, err, err";

        return str;
    }
};
