const std = @import("std");
const TransformMatrix = @import("matrix.zig").TransformMatrix;
const Point = @import("primitives/point.zig").Point;
const Vector = @import("primitives/vector.zig").Vector;

pub const Ray = struct {
    origin: Point,
    direction: Vector,

    const Self = @This();

    pub fn new(origin: Point, direction: Vector) Self {
        return Self{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn position(self: *const Self, t: f32) Point {
        return self.origin.add(&self.direction.scale(t));
    }

    pub fn transform(self: *const Self, orig_transform: *const TransformMatrix) Self {
        const transform_matrix = orig_transform.invert() catch TransformMatrix.identity();

        return Self{
            .origin = self.origin.transform(&transform_matrix),
            .direction = self.direction.transform(&transform_matrix),
        };
    }
};

const expect = std.testing.expect;

test "ray position" {
    const p = Point.new(2, 3, 4);
    const v = Vector.new(1, 0, 0);
    const r = Ray.new(p, v);

    const p1 = r.position(0);
    const p2 = r.position(1);
    const p3 = r.position(-1);
    const p4 = r.position(2.5);

    try expect(p1.eql(&Point.new(2, 3, 4)));
    try expect(p2.eql(&Point.new(3, 3, 4)));
    try expect(p3.eql(&Point.new(1, 3, 4)));
    try expect(p4.eql(&Point.new(4.5, 3, 4)));
}
