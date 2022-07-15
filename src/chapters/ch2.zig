const std = @import("std");

const Canvas = @import("../canvas.zig").Canvas;

const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Vector = @import("../primitives/vector.zig").Vector;

const Projectile = struct {
    pos: Point,
    v: Vector,
};

fn tick(proj: Projectile, g: Vector, res: Vector) Projectile {
    const new_pos = proj.pos.add(&proj.v);
    const new_v = proj.v.add(&g).add(&res);

    const ret = Projectile{
        .pos = new_pos,
        .v = new_v,
    };

    return ret;
}

pub fn final(allocator: std.mem.Allocator) !void {
    const velocity = Vector.new(1, 1.8, 0).normalize().scale(11.25);
    var proj = Projectile{
        .pos = Point.new(0, 1, 0),
        .v = velocity,
    };
    const g = Vector.new(0, -0.1, 0);
    const res = Vector.new(-0.01, 0, 0);

    const width: u32 = 900;
    const height: u32 = 550;
    var pic = try Canvas.new(allocator, width, height);
    const red = Color.new(1, 0, 0);

    while (proj.pos.x < width and proj.pos.y < height and proj.pos.y >= 0) : (proj = tick(proj, g, res)) {
        const x = @floatToInt(u32, @round(proj.pos.x));
        const y = height - @floatToInt(u32, @round(proj.pos.y));

        pic.set(x, y, red);
    }

    _ = try pic.writeToPpm(allocator);
}
