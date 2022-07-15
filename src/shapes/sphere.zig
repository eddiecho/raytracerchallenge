const std = @import("std");

const Color = @import("../primitives/color.zig").Color;
const Light = @import("../shader/light.zig").Light;
const Material = @import("../shader/material.zig").Material;
const Ray = @import("../ray.zig").Ray;
const utils = @import("../utils.zig");
const TransformMatrix = @import("../matrix.zig").TransformMatrix;
const Transform = @import("../transform.zig").Transform;
const Point = @import("../primitives/point.zig").Point;
const Vector = @import("../primitives/vector.zig").Vector;
const _i = @import("../intersection.zig");
const IntersectionPoint = _i.IntersectionPoint;
const Intersection = _i.Intersection;

pub const Sphere = struct {
    id: usize,
    transform: TransformMatrix = TransformMatrix.identity(),
    transformed: bool = false,
    material: Material = Material.default(),

    const Self = @This();

    pub fn new() Self {
        return Self{
            .id = 0,
        };
    }

    pub fn addTransform(self: *Self, transform: Transform) void {
        self.transform = transform.toMatrix().mult(&self.transform);
        self.transformed = true;
    }

    // returns the t values when the ray intersects the sphere
    // only one if tangent, zero if misses
    pub fn intersect(self: *const Self, original_ray: Ray) Intersection {
        const ray = if (self.transformed) original_ray.transform(&self.transform) else original_ray;

        // vector from sphere origin to ray origin
        const sphere_to_ray = ray.origin.sub(&Point.new(0, 0, 0));
        const a = ray.direction.dot(&ray.direction);
        const b = 2.0 * ray.direction.dot(&sphere_to_ray);
        const c = sphere_to_ray.dot(&sphere_to_ray) - 1.0;
        const del = (b * b) - (4 * a * c);

        var point: IntersectionPoint = undefined;
        if (del < 0) {
            point = IntersectionPoint.zero();
        } else if (utils.f32Equals(del, 0.0)) {
            point = IntersectionPoint.one(-b / (2 * a));
        } else {
            const sq = @sqrt(del);
            point = IntersectionPoint.two((-b - sq) / (2 * a), (-b + sq) / (2 * a));
        }

        return Intersection.new(point, @ptrToInt(self));
    }

    pub fn normalAt(self: *const Self, world_point: Point) !Vector {
        if (self.transformed) {
            const inverted = try self.transform.invert();
            const object_point = world_point.transform(&inverted);
            const object_normal = object_point.sub(&Point.new(0, 0, 0));
            var world_normal = object_normal.transform(&inverted.transpose());
            world_normal._data.w = 0;

            return world_normal.normalize();
        } else {
            return world_point.sub(&Point.new(0, 0, 0)).normalize();
        }
    }
};

const expect = std.testing.expect;

test "ray intersection" {
    const s = Sphere.new();
    const p1 = Point.new(0, 0, -5);
    const v1 = Vector.new(0, 0, 1);
    const r1 = Ray.new(p1, v1);

    const xs1 = s.intersect(r1);
    switch (xs1.points) {
        .Zero => unreachable,
        .One => unreachable,
        .Two => |i| {
            try expect(utils.f32Equals(i[0], 4.0));
            try expect(utils.f32Equals(i[1], 6.0));
        },
    }

    const p2 = Point.new(0, 1, -5);
    const v2 = Vector.new(0, 0, 1);
    const r2 = Ray.new(p2, v2);

    const xs2 = s.intersect(r2);
    switch (xs2.points) {
        .Zero => unreachable,
        .One => |i| {
            try expect(utils.f32Equals(i, 5.0));
        },
        .Two => unreachable,
    }

    const p3 = Point.new(0, 2, -5);
    const v3 = Vector.new(0, 0, 1);
    const r3 = Ray.new(p3, v3);

    const xs3 = s.intersect(r3);
    switch (xs3.points) {
        .Zero => try expect(true),
        .One => unreachable,
        .Two => unreachable,
    }
}

test "negative intersection" {
    const s = Sphere.new();
    const p1 = Point.new(0, 0, 0);
    const v1 = Vector.new(0, 0, 1);
    const r1 = Ray.new(p1, v1);

    const xs1 = s.intersect(r1);
    switch (xs1.points) {
        .Zero => unreachable,
        .One => unreachable,
        .Two => |i| {
            try expect(utils.f32Equals(i[0], -1));
            try expect(utils.f32Equals(i[1], 1));
        },
    }

    const p2 = Point.new(0, 0, 5);
    const v2 = Vector.new(0, 0, 1);
    const r2 = Ray.new(p2, v2);
    const xs2 = s.intersect(r2);
    switch (xs2.points) {
        .Zero => unreachable,
        .One => unreachable,
        .Two => |i| {
            try expect(utils.f32Equals(i[0], -6));
            try expect(utils.f32Equals(i[1], -4));
        },
    }
}

test "transformed intersection scalar" {
    var s = Sphere.new();
    const p = Point.new(0, 0, -5);
    const v = Vector.new(0, 0, 1);
    const r = Ray.new(p, v);

    s.addTransform(Transform.scalar(2, 2, 2));
    const xs = s.intersect(r);

    switch (xs.points) {
        .Zero => unreachable,
        .One => unreachable,
        .Two => |i| {
            try expect(utils.f32Equals(i[0], 3));
            try expect(utils.f32Equals(i[1], 7));
        },
    }
}

test "transformed intersection translate" {
    var s = Sphere.new();
    const p = Point.new(0, 0, -5);
    const v = Vector.new(0, 0, 1);
    const r = Ray.new(p, v);

    s.addTransform(Transform.translate(5, 0, 0));
    const xs = s.intersect(r);

    switch (xs.points) {
        .Zero => try expect(true),
        .One => unreachable,
        .Two => unreachable,
    }
}

test "normal untransformed" {
    const s = Sphere.new();

    const n1 = try s.normalAt(Point.new(1, 0, 0));
    const n2 = try s.normalAt(Point.new(0, 1, 0));
    const n3 = try s.normalAt(Point.new(0, 0, 1));
    const n4 = try s.normalAt(Point.new(@sqrt(3.0) / 3.0, @sqrt(3.0) / 3.0, @sqrt(3.0) / 3.0));

    try expect(n1.eql(&Vector.new(1, 0, 0)));
    try expect(n2.eql(&Vector.new(0, 1, 0)));
    try expect(n3.eql(&Vector.new(0, 0, 1)));
    try expect(n4.eql(&Vector.new(@sqrt(3.0) / 3.0, @sqrt(3.0) / 3.0, @sqrt(3.0) / 3.0)));

    try expect(n4.eql(&n4.normalize()));
}

test "normal transformed" {
    var s1 = Sphere.new();
    s1.addTransform(Transform.translate(0, 1, 0));
    const n1 = try s1.normalAt(Point.new(0, 1.70711, -0.70711));
    try expect(n1.eql(&Vector.new(0, 0.70711, -0.70711)));

    var s2 = Sphere.new();
    s2.addTransform(Transform.rotationZ(std.math.pi / 5.0));
    s2.addTransform(Transform.scalar(1, 0.5, 1));
    const n2 = try s2.normalAt(Point.new(0, @sqrt(2.0) / 2.0, -@sqrt(2.0) / 2.0));
    try expect(n2.eql(&Vector.new(0, 0.97014, -0.24254)));
}
