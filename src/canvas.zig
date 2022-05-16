const std = @import("std");
const Color = @import("color.zig").Color;

pub const Canvas = struct {
  data: []Color,
  width: u32,
  height: u32,

  pub fn new(width: u32, height: u32) !Canvas {
    var gpa = std.heap.page_allocator;
    const data = try gpa.alloc(Color, width * height);
    return Canvas {
      .data = data,
      .width = width,
      .height = height,
    };
  }

  pub fn set(self: @This(), x: u32, y: u32, color: Color) void {
    self.data[(y * self.width) + x] = color;
  }

  pub fn get(self: @This(), x: u32, y: u32) Color {
    return self.data[(y * self.width) + x];
  }

  // this might be nuts, might just dump to file instead
  pub fn to_string(self: @This()) []const u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var str = std.fmt.allocPrint(
      gpa.allocator(),
      "{} {}",
      .{self.width, self.height}
    ) catch "err err err";

    return str;
  }
};
