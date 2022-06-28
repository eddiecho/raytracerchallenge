const std = @import("std");
const assert = std.debug.assert;
const sqrt = std.math.sqrt;

const TransformMatrix = @import("../matrix.zig").TransformMatrix;
const utils = @import("../utils.zig");

pub const Tuple = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    const Self = @This();

    pub fn init(x: f32, y: f32, z: f32, w: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };
    }

    pub fn zero() Self {
        return Self{
            .x = 0,
            .y = 0,
            .z = 0,
            .w = 0,
        };
    }

    pub fn eql(self: *const Self, other: *const Self) bool {
        const x = utils.f32_equals(self.x, other.x);
        const y = utils.f32_equals(self.y, other.y);
        const z = utils.f32_equals(self.z, other.z);
        const w = utils.f32_equals(self.w, other.w);

        return (x and y and z and w);
    }

    pub fn elementwiseAdd(self: *const Self, other: *const Self) Self {
        return Self.init(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w);
    }

    pub fn elementwiseSub(self: *const Self, other: *const Self) Self {
        return Self.init(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w);
    }

    // return a new one or inplace replacement?
    pub fn elementwiseNeg(self: *const Self) Self {
        return Self.init(
            -self.x,
            -self.y,
            -self.z,
            -self.w,
        );
    }

    pub fn elementwiseScale(self: *const Self, scalar: f32) Self {
        return Self.init(
            self.x * scalar,
            self.y * scalar,
            self.z * scalar,
            self.w * scalar,
        );
    }

    pub fn elementwiseMult(self: *const Self, other: *const Self) Self {
        return Self.init(
            self.x * other.x,
            self.y * other.y,
            self.z * other.z,
            self.w * other.w,
        );
    }
};

const expect = std.testing.expect;

test "tuple equals" {
    const one = Tuple.init(1.0, -1.0, 1.0, 1);
    const two = Tuple.init(1.0, -1.0, 1.0000001, 1);

    try expect(one.eql(&two));
}

test "tuple negate" {
    const a = Tuple.init(1, -2, 3, -4);
    const c = a.elementwiseNeg();

    try expect(c.eql(&Tuple.init(-1, 2, -3, 4)));
}

test "tuple scale" {
    const a = Tuple.init(1, -2, 3, -4);
    const ac = a.elementwiseScale(3.5);
    try expect(ac.eql(&Tuple.init(3.5, -7, 10.5, -14)));

    const b = Tuple.init(1, -2, 3, -4);
    const bc = b.elementwiseScale(1.0 / 2.0);
    try expect(bc.eql(&Tuple.init(0.5, -1, 1.5, -2)));
}
