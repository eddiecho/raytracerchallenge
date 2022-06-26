const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Tuple = @import("tuple.zig").Tuple;
const utils = @import("utils.zig");
const _i = @import("intersection.zig");
const IntersectionPoint = _i.IntersectionPoint;
const Intersection = _i.Intersection;
const _matrix = @import("matrix.zig");
const SquareMatrix = _matrix.SquareMatrix;
const Transform = _matrix.Transform;

const TransformMatrix = SquareMatrix(4);

pub const Sphere = struct {
  id: usize,
  transforms: std.ArrayList(Transform),

  const Self = @This();

  pub fn new() Self {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    return Self {
      .id = 0,
      .transforms = std.ArrayList(Transform).init(gpa.allocator()),
    };
  }

  pub fn add_transform(self: *Self, transform: Transform) void {
    // oh well
    self.transforms.append(transform) catch unreachable;
  }

  // returns the t values when the ray intersects the sphere
  // only one if tangent, zero if misses
  pub fn intersect(self: *const Self, original_ray: Ray) Intersection {
    // for now self is centered at (0,0,0)
    var ray = original_ray;
    for (self.transforms.items) |xform| {
      ray = switch (xform) {
        .Translate => |t| ray.translate(t[0], t[1], t[2]),
        .Scalar => |s| ray.scale(s[0], s[1], s[2]),
        .Rotation => unreachable,
      };
    }

    // vector from sphere origin to ray origin
    const sphere_to_ray = ray.origin.sub(&Tuple.point(0, 0, 0));
    const a = ray.direction.dot(&ray.direction);
    const b = 2.0 * ray.direction.dot(&sphere_to_ray);
    const c = sphere_to_ray.dot(&sphere_to_ray) - 1.0;
    const del = (b * b) - (4 * a * c);

    var point: IntersectionPoint = undefined;
    if (del < 0) {
      point = IntersectionPoint.zero();
    } else if (utils.f32_equals(del, 0.0)) {
      point = IntersectionPoint.one(-b / (2 * a));
    } else {
      const sq = @sqrt(del);
      point = IntersectionPoint.two((-b - sq) / (2 * a), (-b + sq) / (2 * a));
    }

    return Intersection.new(point, @ptrToInt(self));
  }
};

const expect = std.testing.expect;

test "ray intersection" {
  const s = Sphere.new();
  const p1 = Tuple.point(0, 0, -5);
  const v1 = Tuple.vector(0, 0, 1);
  const r1 = Ray.new(p1, v1);

  const xs1 = s.intersect(r1);
  switch (xs1.points) {
    .Zero => unreachable,
    .One => unreachable,
    .Two => |i| {
      try expect(utils.f32_equals(i[0], 4.0));
      try expect(utils.f32_equals(i[1], 6.0));
    }
  }

  const p2 = Tuple.point(0, 1, -5);
  const v2 = Tuple.vector(0, 0, 1);
  const r2 = Ray.new(p2, v2);

  const xs2 = s.intersect(r2);
  switch (xs2.points) {
    .Zero => unreachable,
    .One => |i| {
      try expect(utils.f32_equals(i, 5.0));
    },
    .Two => unreachable,
  }

  const p3 = Tuple.point(0, 2, -5);
  const v3 = Tuple.vector(0, 0, 1);
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
  const p1 = Tuple.point(0, 0, 0);
  const v1 = Tuple.vector(0, 0, 1);
  const r1 = Ray.new(p1, v1);

  const xs1 = s.intersect(r1);
  switch (xs1.points) {
    .Zero => unreachable,
    .One => unreachable,
    .Two => |i| {
      try expect(utils.f32_equals(i[0], -1));
      try expect(utils.f32_equals(i[1], 1));
    }
  }

  const p2 = Tuple.point(0, 0, 5);
  const v2 = Tuple.vector(0, 0, 1);
  const r2 = Ray.new(p2, v2);
  const xs2 = s.intersect(r2);
  switch (xs2.points) {
    .Zero => unreachable,
    .One => unreachable,
    .Two => |i| {
      try expect(utils.f32_equals(i[0], -6));
      try expect(utils.f32_equals(i[1], -4));
    }
  }
}

test "transformed intersection scalar" {
  var s = Sphere.new();
  const p = Tuple.point(0, 0, -5);
  const v = Tuple.vector(0, 0, 1);
  const r = Ray.new(p, v);

  s.add_transform(Transform { .Scalar = .{2, 2, 2} });
  const xs = s.intersect(r);

  switch (xs.points) {
    .Zero => unreachable,
    .One => unreachable,
    .Two => |i| {
      try expect(utils.f32_equals(i[0], 3));
      try expect(utils.f32_equals(i[1], 7));
    }
  }
}

test "transformed intersection translate" {
  var s = Sphere.new();
  const p = Tuple.point(0, 0, -5);
  const v = Tuple.vector(0, 0, 1);
  const r = Ray.new(p, v);

  s.add_transform(Transform { .Translate = .{5, 0, 0}});
  const xs = s.intersect(r);

  switch (xs.points) {
    .Zero => try expect(true),
    .One => unreachable,
    .Two => unreachable,
  }
}
