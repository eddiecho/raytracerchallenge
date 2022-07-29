const std = @import("std");

const Canvas = @import("../canvas.zig").Canvas;
const Ray = @import("../ray.zig").Ray;
const Sphere = @import("../shapes/sphere.zig").Sphere;
const Transform = @import("../transform.zig").Transform;

const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Vector = @import("../primitives/vector.zig").Vector;

pub fn final(allocator: std.mem.Allocator) !void {
    const width: u32 = 1024;
    const height: u32 = 1024;
    var pic = try Canvas.new(allocator, width, height);

    const red = Color.new(1, 0, 0);
    const ray_origin = Point.new(0, 0, -5);
    const wall_size: f32 = 8.0;
    const wall_z: f32 = 10.0;
    const increment: f32 = 2 * wall_size / @intToFloat(f32, width);
    const sphere = Sphere.new();

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
            const direction = wall_point.sub(&ray_origin);
            const ray = Ray.new(ray_origin, direction);

            const intersection = sphere.intersect(&ray);
            switch (intersection.points) {
                .Zero => continue,
                .One, .Two => pic.set(x, y, red),
            }
        }
    }

    _ = try pic.writeToPpm(allocator);
}
