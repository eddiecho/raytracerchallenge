const Color = @import("../primitives/color.zig").Color;

pub const Material = struct {
    color: Color = Color.new(1, 1, 1),
    ambient: f32 = 0.1,
    diffuse: f32 = 0.9,
    specular: f32 = 0.9,
    shininess: f32 = 200.0,

    const Self = @This();

    pub fn default() Self {
        return Self{ };
    }
};
