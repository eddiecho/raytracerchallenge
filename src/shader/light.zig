const std = @import("std");
const Color = @import("../primitives/color.zig").Color;
const Point = @import("../primitives/point.zig").Point;
const Material = @import("material.zig").Material;
const Vector = @import("../primitives/vector.zig").Vector;

pub const Light = struct {
    intensity: Color,
    position: Point,

    const Self = @This();

    pub fn point(intensity: Color, position: Point) Self {
        return Self{
            .intensity = intensity,
            .position = position,
        };
    }
};

pub fn lightAt(material: *const Material, obj_point: *const Point, light: *const Light, camera: *const Vector, normal: *const Vector) Color {
    const effective_color = material.color.mult(&light.intensity);
    const ambient = effective_color.scale(material.ambient);

    const light_direction = light.position.sub(obj_point).normalize();
    const light_dot_normal = light_direction.dot(normal);

    var diffuse = Color.new(0, 0, 0);
    var specular = Color.new(0, 0, 0);

    if (light_dot_normal >= 0) {
        diffuse = effective_color.scale(material.diffuse * light_dot_normal);
        const reflect_direction = light_direction.scale(-1).reflect(normal);
        const reflect_dot_camera = reflect_direction.dot(camera);

        if (reflect_dot_camera > 0) {
            const factor = std.math.pow(f32, reflect_dot_camera, material.shininess);
            specular = light.intensity.scale(material.specular * factor);
        }
    }

    return ambient.add(&diffuse).add(&specular);
}

const expect = std.testing.expect;

test "direct sight" {
    const material = Material.default();
    const world_position = Point.new(0, 0, 0);

    const eye = Vector.new(0, 0, -1);
    const normal = Vector.new(0, 0, -1);
    const light = Light.point(Color.new(1, 1, 1), Point.new(0, 0, -10));
    const test1 = lightAt(&material, &world_position, &light, &eye, &normal);
    try expect(test1.eql(&Color.new(1.9, 1.9, 1.9)));
}

test "camera 45 degree" {
    const material = Material.default();
    const world_position = Point.new(0, 0, 0);

    const eye = Vector.new(0, @sqrt(2.0) / 2.0, @sqrt(2.0) / 2.0);
    const normal = Vector.new(0, 0, -1);
    const light = Light.point(Color.new(1, 1, 1), Point.new(0, 0, -10));
    const test1 = lightAt(&material, &world_position, &light, &eye, &normal);
    try expect(test1.eql(&Color.new(1.0, 1.0, 1.0)));
}

test "light 45 degree" {
    const material = Material.default();
    const world_position = Point.new(0, 0, 0);

    const eye = Vector.new(0, 0, -1);
    const normal = Vector.new(0, 0, -1);
    const light = Light.point(Color.new(1, 1, 1), Point.new(0, 10, -10));
    const test1 = lightAt(&material, &world_position, &light, &eye, &normal);
    try expect(test1.eql(&Color.new(0.7364, 0.7364, 0.7364)));
}

test "camera and light 45 degree" {
    const material = Material.default();
    const world_position = Point.new(0, 0, 0);

    const eye = Vector.new(0, -@sqrt(2.0) / 2.0, -@sqrt(2.0) / 2.0);
    const normal = Vector.new(0, 0, -1);
    const light = Light.point(Color.new(1, 1, 1), Point.new(0, 10, -10));
    const test1 = lightAt(&material, &world_position, &light, &eye, &normal);
    try expect(test1.eql(&Color.new(1.6364, 1.6364, 1.6364)));
}

test "light behind" {
    const material = Material.default();
    const world_position = Point.new(0, 0, 0);

    const eye = Vector.new(0, 0, -1);
    const normal = Vector.new(0, 0, -1);
    const light = Light.point(Color.new(1, 1, 1), Point.new(0, 0, 10));
    const test1 = lightAt(&material, &world_position, &light, &eye, &normal);

    try expect(test1.eql(&Color.new(0.1, 0.1, 0.1)));
}
