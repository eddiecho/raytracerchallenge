const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const TransformMatrix = @import("../matrix.zig").TransformMatrix;
const utils = @import("../utils.zig");
const Vector = @import("vector.zig").Vector;

pub const Point = struct {
    _data: Tuple,

    const Self = @This();

    pub fn new(x: f32, y: f32, z: f32) Self {
        return Self{
            ._data = Tuple.init(x, y, z, 1),
        };
    }

    pub fn X(self: *const Self) f32 {
        return self._data.x;
    }

    pub fn Y(self: *const Self) f32 {
        return self._data.y;
    }

    pub fn Z(self: *const Self) f32 {
        return self._data.z;
    }

    // points can only be added to vectors, not to each other
    pub fn add(self: *const Self, vec: *const Vector) Self {
        return Self{
            ._data = self._data.elementwiseAdd(&vec._data),
        };
    }

    pub fn subVec(self: *const Self, vec: *const Vector) Self {
        return Self{
            ._data = self._data.elementwiseSub(&vec._data),
        };
    }

    pub fn sub(self: *const Self, other: *const Self) Vector {
        return Vector{
            ._data = self._data.elementwiseSub(&other._data),
        };
    }

    pub fn eql(self: *const Self, other: *const Self) bool {
        const x = utils.f32Equals(self.X(), other.X());
        const y = utils.f32Equals(self.Y(), other.Y());
        const z = utils.f32Equals(self.Z(), other.Z());

        return (x and y and z);
    }

    pub fn transform(self: *const Self, matrix: *const TransformMatrix) Self {
        return Self{
            ._data = matrix.multVec(&self._data),
        };
    }
};

const expect = std.testing.expect;

test "sub vector from point" {
    const p = Point.new(3, 2, 1);
    const v = Vector.new(5, 6, 7);

    const pv = p.subVec(&v);
    try expect(pv.eql(&Point.new(-2, -4, -6)));
}

test "sub two points" {
    const a = Point.new(3, 2, 1);
    const b = Point.new(5, 6, 7);

    const c = a.sub(&b);
    try expect(c.eql(&Vector.new(-2, -4, -6)));
}
