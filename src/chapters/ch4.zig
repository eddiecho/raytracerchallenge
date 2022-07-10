const std = @import("std");

const Canvas = @import("../canvas.zig").Canvas;
const Transform = @import("../transform.zig").Transform;

const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Vector = @import("../primitives/vector.zig").Vector;

fn set(pic: *Canvas, point: Point, color: Color) void {
    pic.set(@floatToInt(u32, point.X()), @floatToInt(u32, point.Y()), color);
}

pub fn final(allocator: std.mem.Allocator) !void {
    const width: u32 = 500;
    const height: u32 = 500;
    var pic = try Canvas.new(allocator, width, height);
    const white = Color.new(1, 1, 1);

    const origin = Point.new(0, 0, 0);
    var radian: f32 = 0.0;
    var it: usize = 0;

    // ultimately, its more stable to calculate from an offset instead of adding radian repeatedly, but its fine for now
    while (it < 12) : ({
        it += 1;
        radian += (std.math.pi / 6.0);
    }) {
        const init = Transform.translation(0, 200, 0).toMatrix();
        const rotation = Transform.rotationZ(radian).toMatrix();
        const final = Transform.translation(250, 250, 0).toMatrix();

        const transform = final.mult(&rotation).mult(&init);
        const point = transform.multVec(&origin);
        set(&pic, point, white);
    }

    _ = try pic.writeToPpm(allocator);
}

