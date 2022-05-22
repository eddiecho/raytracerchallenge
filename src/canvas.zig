const std = @import("std");
const assert = std.debug.assert;
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
    assert(x >= 0 and x < self.width);
    assert(y >= 0 and y < self.height);
    self.data[(y * self.width) + x] = color;
  }

  pub fn get(self: @This(), x: u32, y: u32) Color {
    assert(x >= 0 and x < self.width);
    assert(y >= 0 and y < self.height);
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

    // ppm spec says lines shouldn't be longer than 70 chars
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var bytes_written: usize = 0;

    bytes_written += try file.write("P3\n");
    {
      const str = std.fmt.allocPrint(
        allocator,
        "{} {}\n",
        .{ self.width, self.height }
      ) catch "0 0\n";
      bytes_written += try file.write(str);
      bytes_written += try file.write("255\n");
    }

    const len = self.width * self.height;
    {
      var i: usize = 0;
      // manually unroll the loop
      while (i + 5 < len) : (i += 5) {
        const one = self.data[i].to_32bit();
        const two = self.data[i + 1].to_32bit();
        const thr = self.data[i + 2].to_32bit();
        const fou = self.data[i + 3].to_32bit();
        const fiv = self.data[i + 4].to_32bit();

        const str = try std.fmt.allocPrint(
          allocator,
          "{} {} {} {} {} {} {} {} {} {} {} {} {} {} {}\n",
          .{
            one[0], one[1], one[2],
            two[0], two[1], two[2],
            thr[0], thr[1], thr[2],
            fou[0], fou[1], fou[2],
            fiv[0], fiv[1], fiv[2],
          }
        );

        bytes_written += try file.write(str);
      }

      while (i < len) : (i += 1) {
        const col = self.data[i].to_32bit();
        const str = try std.fmt.allocPrint(
          allocator,
          "{} {} {} ",
          .{ col[0], col[1], col[2] }
        );

        bytes_written += try file.write(str);
      }
    }

    bytes_written += try file.write("\n");

    return bytes_written;
  }
};
