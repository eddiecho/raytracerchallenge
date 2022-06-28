const std = @import("std");
const Point = @import("point.zig").Point;
const Tuple = @import("tuple.zig").Tuple;
const utils = @import("../utils.zig");
const TransformMatrix = @import("../matrix.zig").TransformMatrix;

pub const Vector = struct {
    _data: Tuple,

    const Self = @This();

    pub fn new(x: f32, y: f32, z: f32) Self {
        return Self{
            ._data = Tuple.init(x, y, z, 0),
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

    pub fn add(self: *const Self, vec: *const Self) Self {
        return Self{
            ._data = self._data.elementwiseAdd(&vec._data),
        };
    }

    pub fn addPoint(self: *const Self, point: *const Point) Point {
        return Point{
            ._data = self._data.elementwiseAdd(&point._data),
        };
    }

    // order matters for sub
    pub fn sub(self: *const Self, other: *const Self) Self {
        return Self{
            ._data = self._data.elementwiseSub(&other._data),
        };
    }

    pub fn eql(self: *const Self, other: *const Self) bool {
        const x = utils.f32Equals(self.X(), other.X());
        const y = utils.f32Equals(self.Y(), other.Y());
        const z = utils.f32Equals(self.Z(), other.Z());

        return (x and y and z);
    }

    pub fn scale(self: *const Self, scalar: f32) Self {
        return Self{
            ._data = self._data.elementwiseScale(scalar),
        };
    }

    pub fn dot(self: *const Self, other: *const Self) f32 {
        return (self.X() * other.X()) +
            (self.Y() * other.Y()) +
            (self.Z() * other.Z());
    }

    pub fn magnitude(self: *const Self) f32 {
        const sum = self.dot(self);
        return @sqrt(sum);
    }

    pub fn normalize(self: *const Self) Self {
        const len = self.magnitude();
        return self.scale(1.0 / len);
    }

    pub fn cross(self: *const Self, other: *const Self) Self {
        const data = Tuple{
            .x = (self.Y() * other.Z()) - (self.Z() * other.Y()),
            .y = (self.Z() * other.X()) - (self.X() * other.Z()),
            .z = (self.X() * other.Y()) - (self.Y() * other.X()),
            .w = 0,
        };

        return Self{
            ._data = data,
        };
    }

    pub fn transform(self: *const Self, matrix: *const TransformMatrix) Self {
        return Self{
            ._data = matrix.multVec(&self._data),
        };
    }
};

const expect = std.testing.expect;

test "add with point" {
    const a = Vector.new(-2, 3, 1);
    const b = Point.new(3, -2, 5);

    const c = a.addPoint(&b);

    try expect(c.eql(&Point.new(1, 1, 6)));
}

test "sub two vectors" {
    const a = Vector.new(3, 2, 1);
    const b = Vector.new(5, 6, 7);

    const c = a.sub(&b);
    try expect(c.eql(&Vector.new(-2, -4, -6)));
}

test "magnitude" {
    const a = Vector.new(1, 0, 0);
    try expect(utils.f32Equals(a.magnitude(), 1.0));

    const b = Vector.new(0, 1, 0);
    try expect(utils.f32Equals(b.magnitude(), 1.0));

    const c = Vector.new(0, 0, 1);
    try expect(utils.f32Equals(c.magnitude(), 1.0));

    const d = Vector.new(1, 2, 3);
    try expect(utils.f32Equals(d.magnitude(), @sqrt(14.0)));

    const e = Vector.new(-1, -2, -3);
    try expect(utils.f32Equals(e.magnitude(), @sqrt(14.0)));
}

test "normalize" {
    const a = Vector.new(4, 0, 0);
    const an = a.normalize();
    try expect(an.eql(&Vector.new(1, 0, 0)));

    const b = Vector.new(1, 2, 3);
    const bn = b.normalize();
    try expect(bn.eql(&Vector.new(0.26726, 0.53453, 0.80178)));
    try expect(utils.f32Equals(bn.magnitude(), 1.0));
}

test "dot product" {
    const a = Vector.new(1, 2, 3);
    const b = Vector.new(2, 3, 4);
    try expect(utils.f32Equals(a.dot(&b), 20));
}

test "cross product" {
    const a = Vector.new(1, 2, 3);
    const b = Vector.new(2, 3, 4);
    const ab = a.cross(&b);
    const ba = b.cross(&a);

    try expect(ab.eql(&Vector.new(-1, 2, -1)));
    try expect(ba.eql(&Vector.new(1, -2, 1)));
}
