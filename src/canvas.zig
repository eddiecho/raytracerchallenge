const std = @import("std");
const Color = @import("color.zig").Color;

pub const Canvas = struct {
  data: []Color,
  width: u32,
  height: u32,

  pub fn new(allocator: std.mem.Allocator, width: u32, height: u32) !Canvas {
    const data = try allocator.alloc(Color, width * height);
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
  pub fn to_string(self: @This(), allocator: std.mem.Allocator) []const u8 {
    var str = std.fmt.allocPrint(
      allocator,
      "{} {}",
      .{self.width, self.height}
    ) catch "err err err";

    return str;
  }

  pub fn writeToPpm(self: @This()) anyerror!usize {
    const file = try std.fs.cwd().createFile(
      "canvas.ppm",
      .{ .read = true },
    );
    defer file.close();

    var buffer: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var ret: usize = 0;

    var bytes_written = try file.write("P3\n");
    ret += bytes_written;

    var str = std.fmt.allocPrint(
      allocator,
      "{} {}\n",
      .{ self.width, self.height }
    ) catch "0 0";
    bytes_written = try file.write(str);
    ret += bytes_written;

    return ret;
  }
};
