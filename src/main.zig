const std = @import("std");
const Tuple = @import("tuple.zig").Tuple;
const Color = @import("color.zig").Color;
const Canvas = @import("canvas.zig").Canvas;
const SquareMatrix = @import("matrix.zig").SquareMatrix;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    // try ch2_final(gpa.allocator());
    // try ch4_final(gpa.allocator());
    try ch5_final(gpa.allocator());
}

const Projectile = struct {
    pos: Tuple,
    v: Tuple,
};

fn tick(proj: Projectile, g: Tuple, res: Tuple) Projectile {
    const new_pos = proj.pos.add(&proj.v);
    const new_v = proj.v.add(&g).add(&res);

    const ret = Projectile{
        .pos = new_pos,
        .v = new_v,
    };

    return ret;
}

fn ch2_final(allocator: std.mem.Allocator) !void {
    const velocity = Tuple.vector(1, 1.8, 0).normalize().scale(11.25);
    var proj = Projectile{
        .pos = Tuple.point(0, 1, 0),
        .v = velocity,
    };
    const g = Tuple.vector(0, -0.1, 0);
    const res = Tuple.vector(-0.01, 0, 0);

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

const Matrix = SquareMatrix(4);

fn ch4_set(pic: *Canvas, point: Tuple, color: Color) void {
    pic.set(@floatToInt(u32, point.x), @floatToInt(u32, point.y), color);
}

fn ch4_final(allocator: std.mem.Allocator) !void {
    const width: u32 = 500;
    const height: u32 = 500;
    var pic = try Canvas.new(allocator, width, height);
    const white = Color.new(1, 1, 1);

    const origin = Tuple.point(0, 0, 0);
    var radian: f32 = 0.0;
    var it: usize = 0;

    // ultimately, its more stable to calculate from an offset instead of adding radian repeatedly, but its fine for now
    while (it < 12) : ({
        it += 1;
        radian += (std.math.pi / 6.0);
    }) {
        const init = Matrix.translation(0, 200, 0);
        const rotation = Matrix.rotation_z(radian);
        const final = Matrix.translation(250, 250, 0);

        const transform = final.mult(&rotation).mult(&init);
        const point = transform.mult_vec(&origin);
        ch4_set(&pic, point, white);
    }

    _ = try pic.writeToPpm(allocator);
}

fn ch5_final(allocator: std.mem.Allocator) !void {
    const width: u32 = 1024;
    const height: u32 = 1024;
    var pic = try Canvas.new(allocator, width, height);

    const red = Color.new(1, 0, 0);
    const ray_origin = Tuple.point(0, 0, -5);
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
            const direction = Tuple.point(wall_x, wall_y, wall_z).sub(&ray_origin);
            const ray = Ray.new(ray_origin, direction);

            const intersection = sphere.intersect(ray);
            switch (intersection.points) {
                .Zero => continue,
                .One, .Two => pic.set(x, y, red),
            }
        }
    }

    _ = try pic.writeToPpm(allocator);
}

test "all" {
    std.testing.refAllDecls(@This());
}
