const std = @import("std");
const SquareMatrix = @import("matrix.zig").SquareMatrix;
const Tuple = @import("tuple.zig").Tuple;

const TransformMatrix = SquareMatrix(4);

pub const Transform = union(enum) {
    Translate: [3]f32,
    Scalar: [3]f32,
    RotationX: f32,
    RotationY: f32,
    RotationZ: f32,
    Shear: [6]f32,

    const Self = @This();

    pub fn translate(x: f32, y: f32, z: f32) Self {
        return Self{ .Translate = .{ x, y, z } };
    }

    pub fn scalar(x: f32, y: f32, z: f32) Self {
        return Self{ .Scalar = .{ x, y, z } };
    }

    pub fn rotation_x(r: f32) Self {
        return Self{ .RotationX = r };
    }

    pub fn rotation_y(r: f32) Self {
        return Self{ .RotationY = r };
    }

    pub fn rotation_z(r: f32) Self {
        return Self{ .RotationZ = r };
    }

    pub fn shear(xy: f32, xz: f32, yx: f32, yz: f32, zx: f32, zy: f32) Self {
        return Self{ .Shear = .{ xy, xz, yx, yz, zx, zy } };
    }

    pub fn toMatrix(transform: Self) TransformMatrix {
        return switch (transform) {
            .Translate => |t| translation_matrix(t[0], t[1], t[2]),
            .Scalar => |s| scaling_matrix(s[0], s[1], s[2]),
            .RotationX => |r| rotation_x_matrix(r),
            .RotationY => |r| rotation_y_matrix(r),
            .RotationZ => |r| rotation_z_matrix(r),
            .Shear => |s| shear_matrix(s[0], s[1], s[2], s[3], s[4], s[5]),
        };
    }
};

fn translation_matrix(x: f32, y: f32, z: f32) TransformMatrix {
    var ret = TransformMatrix.identity();
    ret.set(0, 3, x);
    ret.set(1, 3, y);
    ret.set(2, 3, z);

    return ret;
}

fn scaling_matrix(x: f32, y: f32, z: f32) TransformMatrix {
    var ret = TransformMatrix.identity();

    ret.set(0, 0, x);
    ret.set(1, 1, y);
    ret.set(2, 2, z);

    return ret;
}

fn rotation_x_matrix(r: f32) TransformMatrix {
    var ret = TransformMatrix.identity();

    ret.set(1, 1, @cos(r));
    ret.set(1, 2, -@sin(r));
    ret.set(2, 1, @sin(r));
    ret.set(2, 2, @cos(r));

    return ret;
}

fn rotation_y_matrix(r: f32) TransformMatrix {
    var ret = TransformMatrix.identity();

    ret.set(0, 0, @cos(r));
    ret.set(0, 2, @sin(r));
    ret.set(2, 0, -@sin(r));
    ret.set(2, 2, @cos(r));

    return ret;
}

fn rotation_z_matrix(r: f32) TransformMatrix {
    var ret = TransformMatrix.identity();

    ret.set(0, 0, @cos(r));
    ret.set(0, 1, -@sin(r));
    ret.set(1, 0, @sin(r));
    ret.set(1, 1, @cos(r));

    return ret;
}

fn shear_matrix(xy: f32, xz: f32, yx: f32, yz: f32, zx: f32, zy: f32) TransformMatrix {
    var ret = TransformMatrix.identity();

    ret.set(0, 1, xy);
    ret.set(0, 2, xz);
    ret.set(1, 0, yx);
    ret.set(1, 2, yz);
    ret.set(2, 0, zx);
    ret.set(2, 1, zy);

    return ret;
}

test "translation" {
    const transform = Transform.translate(5, -3, 2).toMatrix();

    const p = Tuple.point(-3, 4, 5);
    const new_p = transform.mult_vec(&p);
    const reverse = p.transform(&transform);
    const expected = Tuple.point(2, 1, 7);

    try std.testing.expect(new_p.eql(&expected));
    try std.testing.expect(reverse.eql(&expected));

    const v = Tuple.vector(-3, 4, 5);
    try std.testing.expect(transform.mult_vec(&v).eql(&v));
}

test "scaling" {
    const transform = Transform.scalar(2, 3, 4).toMatrix();

    const p = Tuple.point(-4, 6, 8);
    const new_p = transform.mult_vec(&p);
    try std.testing.expect(new_p.eql(&Tuple.point(-8, 18, 32)));

    const v = Tuple.vector(-4, 6, 8);
    const new_v = transform.mult_vec(&v);
    try std.testing.expect(new_v.eql(&Tuple.vector(-8, 18, 32)));

    const t_inv = try transform.invert();
    try std.testing.expect(t_inv.mult_vec(&v).eql(&Tuple.vector(-2, 2, 2)));
}

test "rotation x" {
    const pi = std.math.pi;

    const rotation_45 = Transform.rotation_x(pi / 4.0).toMatrix();
    const rotation_90 = Transform.rotation_x(pi / 2.0).toMatrix();
    const p = Tuple.point(0, 1, 0);

    const p_45 = rotation_45.mult_vec(&p);
    const p_90 = rotation_90.mult_vec(&p);

    try std.testing.expect(p_45.eql(&Tuple.point(0, @sqrt(2.0) / 2.0, @sqrt(2.0) / 2.0)));
    try std.testing.expect(p_90.eql(&Tuple.point(0, 0, 1)));
}

test "rotation_y" {
    const pi = std.math.pi;

    const rot_45 = Transform.rotation_y(pi / 4.0).toMatrix();
    const rot_90 = Transform.rotation_y(pi / 2.0).toMatrix();
    const p = Tuple.point(0, 0, 1);

    const p_45 = rot_45.mult_vec(&p);
    const p_90 = rot_90.mult_vec(&p);

    try std.testing.expect(p_45.eql(&Tuple.point(@sqrt(2.0) / 2.0, 0, @sqrt(2.0) / 2.0)));
    try std.testing.expect(p_90.eql(&Tuple.point(1, 0, 0)));
}

test "rotation_z" {
    const pi = std.math.pi;

    const rot_45 = Transform.rotation_z(pi / 4.0).toMatrix();
    const rot_90 = Transform.rotation_z(pi / 2.0).toMatrix();
    const p = Tuple.point(0, 1, 0);

    const p_45 = rot_45.mult_vec(&p);
    const p_90 = rot_90.mult_vec(&p);

    try std.testing.expect(p_45.eql(&Tuple.point(-@sqrt(2.0) / 2.0, @sqrt(2.0) / 2.0, 0)));
    try std.testing.expect(p_90.eql(&Tuple.point(-1, 0, 0)));
}

test "shear" {
    const p = Tuple.point(2, 3, 4);

    const s1 = Transform.shear(1, 0, 0, 0, 0, 0).toMatrix();
    const s2 = Transform.shear(0, 1, 0, 0, 0, 0).toMatrix();
    const s3 = Transform.shear(0, 0, 1, 0, 0, 0).toMatrix();
    const s4 = Transform.shear(0, 0, 0, 1, 0, 0).toMatrix();
    const s5 = Transform.shear(0, 0, 0, 0, 1, 0).toMatrix();
    const s6 = Transform.shear(0, 0, 0, 0, 0, 1).toMatrix();

    const p1 = s1.mult_vec(&p);
    const p2 = s2.mult_vec(&p);
    const p3 = s3.mult_vec(&p);
    const p4 = s4.mult_vec(&p);
    const p5 = s5.mult_vec(&p);
    const p6 = s6.mult_vec(&p);

    try std.testing.expect(p1.eql(&Tuple.point(5, 3, 4)));
    try std.testing.expect(p2.eql(&Tuple.point(6, 3, 4)));
    try std.testing.expect(p3.eql(&Tuple.point(2, 5, 4)));
    try std.testing.expect(p4.eql(&Tuple.point(2, 7, 4)));
    try std.testing.expect(p5.eql(&Tuple.point(2, 3, 6)));
    try std.testing.expect(p6.eql(&Tuple.point(2, 3, 7)));
}

test "chaining" {
    const p = Tuple.point(1, 0, 1);

    const a = Transform.rotation_x(std.math.pi / 2.0).toMatrix();
    const b = Transform.scalar(5, 5, 5).toMatrix();
    const c = Transform.translate(10, 5, 7).toMatrix();

    const p2 = a.mult_vec(&p);
    try std.testing.expect(p2.eql(&Tuple.point(1, -1, 0)));

    const p3 = b.mult_vec(&p2);
    try std.testing.expect(p3.eql(&Tuple.point(5, -5, 0)));

    const p4 = c.mult_vec(&p3);
    try std.testing.expect(p4.eql(&Tuple.point(15, 0, 7)));

    const transform = c.mult(&b).mult(&a);
    const p1 = transform.mult_vec(&p);
    try std.testing.expect(p1.eql(&Tuple.point(15, 0, 7)));
}
