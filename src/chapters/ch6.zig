const std = @import("std");

const Canvas = @import("../canvas.zig").Canvas;
const Ray = @import("../ray.zig").Ray;
const Sphere = @import("../shapes/sphere.zig").Sphere;
const Transform = @import("../transform.zig").Transform;
const light = @import("../shader/light.zig");

const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Vector = @import("../primitives/vector.zig").Vector;

fn get_color(sphere: *const Sphere, ray: *const Ray, point_light: *const light.Light, t: f32) !Color {
    const obj_point = ray.position(t);
    const normal = try sphere.normalAt(obj_point);
    const eye = ray.direction.scale(-1);

    return light.lightAt(
        &sphere.material,
        &obj_point,
        point_light,
        &eye,
        &normal
    );
}

pub fn final(allocator: std.mem.Allocator) !void {
    const width: u32 = 1024;
    const height: u32 = 1024;
    var pic = try Canvas.new(allocator, width, height);

    const ray_origin = Point.new(0, 0, -5);
    const wall_size: f32 = 8.0;
    const wall_z: f32 = 10.0;
    const increment: f32 = 2 * wall_size / @intToFloat(f32, width);
    var sphere = Sphere.new();
    sphere.material.color = Color.new(1, 0.2, 1);
    sphere.addTransform(Transform.translate(0, 0.4, 0));
    sphere.addTransform(Transform.shear(0, 0, 1, 0, 0, 1));

    const point_light = light.Light.point(Color.new(1, 1, 1), Point.new(-10, 10, -10));

    var wall_y: f32 = wall_size;
    var y: u32 = 0;
    while (y < height) : ({
        y += 1;
        wall_y -= increment;
    }) {
        var wall_x: f32 = -wall_size;
        var x: u32 = 0;
        while (x < width) : ({
            x += 1;
            wall_x += increment;
        }) {
            const wall_point = Point.new(wall_x, wall_y, wall_z);
            const direction = wall_point.sub(&ray_origin).normalize();
            const ray = Ray.new(ray_origin, direction);

            const intersection = sphere.intersect(ray);
            switch (intersection.points) {
                .Zero => continue,
                .One => |p| {
                    const color = try get_color(&sphere, &ray, &point_light, p);
                    pic.set(x, y, color);
                },
                .Two => |ps| {
                    const color = try get_color(&sphere, &ray, &point_light, ps[0]);
                    pic.set(x, y, color);
                }
            }
        }
    }

    _ = try pic.writeToPpm(allocator);
}
