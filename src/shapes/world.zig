const std = @import("std");

const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Light = @import("../shader/light.zig").Light;
const i_ = @import("../intersection.zig");
const Intersection = i_.Intersection;
const Collision = i_.Collision;
const Ray = @import("../ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const Transform = @import("../transform.zig").Transform;
const Vector = @import("../primitives/vector.zig").Vector;

const ObjectList = std.ArrayList(Sphere);

pub const World = struct {
    light: Light = Light.point(Color.new(1, 1, 1), Point.new(10, -10, 10)),
    objects: ObjectList,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn default(allocator: std.mem.Allocator) !Self {
        var objects = ObjectList.init(allocator);
        var s1 = Sphere.new();
        s1.material.color = Color.new(0.8, 1.0, 0.6);
        s1.material.diffuse = 0.7;
        s1.material.specular = 0.2;
        try objects.append(s1);

        var s2 = Sphere.new();
        s2.addTransform(Transform.scalar(0.5, 0.5, 0.5));
        try objects.append(s2);

        return Self{
            .objects = objects,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Self) void {
        self.objects.deinit();
    }

    pub fn intersect(self: *const Self, ray: Ray) !std.ArrayList(Collision) {
        var ret = std.ArrayList(Collision).init(self.allocator);

        var i: usize = 0;
        for (self.objects.items) |sphere| {
            var intersection = sphere.intersect(ray);

            switch (intersection.points) {
                .Zero => continue,
                .One => |x| {
                    try ret.append(Collision{
                        .object_idx = i,
                        .t = x,
                    });
                },
                .Two => |xs| {
                    try ret.append(Collision{
                        .object_idx = i,
                        .t = xs[0],
                    });
                    try ret.append(Collision{
                        .object_idx = i,
                        .t = xs[1],
                    });
                }
            }

            i += 1;
        }

        return ret;
    }

    const HitData = struct {
        t: f32,
        object_idx: usize,
        point: Point,
        eye_v: Vector,
        normal_v: Vector,
    };

    pub fn collisionData(self: *const Self, collision: Collision, ray: Ray) HitData {
        const point = ray.position(collision.t);

        return HitData{
            .t = collision.t,
            .object_idx = collision.object_idx,
            .point = point,
            .eye_v = ray.direction.scale(-1),
            .normal_v = self.objects.items[collision.object_idx].normalAt(point),
        };
    }
};

const expect = std.testing.expect;

test "default world intersection" {
    var alloc = std.testing.allocator;
    const world = try World.default(alloc);
    defer world.deinit();
    const ray = Ray.new(Point.new(0, 0, -5), Vector.new(0, 0, 1));

    const xs = try world.intersect(ray);
    i_.sortCollisions(xs);
    defer xs.deinit();

    try expect(xs.items.len == 4);
    try std.testing.expectApproxEqAbs(xs.items[0].t, 4.0, 0.00001);
    try std.testing.expectApproxEqAbs(xs.items[1].t, 4.5, 0.00001);
    try std.testing.expectApproxEqAbs(xs.items[2].t, 5.5, 0.00001);
    try std.testing.expectApproxEqAbs(xs.items[3].t, 6.0, 0.00001);
}
