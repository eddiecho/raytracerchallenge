const std = @import("std");
const assert = std.debug.assert;
const Color = @import("primitives/color.zig").Color;

pub const Canvas = struct {
    data: []Color,
    width: u32,
    height: u32,

    const Self = @This();

    pub fn new(allocator: std.mem.Allocator, width: u32, height: u32) !Self {
        const data = try allocator.alloc(Color, width * height);
        return Self{
            .data = data,
            .width = width,
            .height = height,
        };
    }

    pub fn set(self: *Self, x: u32, y: u32, color: Color) void {
        assert(x >= 0 and x < self.width);
        assert(y >= 0 and y < self.height);
        self.data[(y * self.width) + x] = color;
    }

    pub fn get(self: *Self, x: u32, y: u32) Color {
        assert(x >= 0 and x < self.width);
        assert(y >= 0 and y < self.height);
        return self.data[(y * self.width) + x];
    }

    pub fn writeToPpm(self: *const Self, base_alloc: std.mem.Allocator) anyerror!usize {
        const file = try std.fs.cwd().createFile(
            "canvas.ppm",
            .{ .read = true },
        );
        defer file.close();

        // ppm spec says lines shouldn't be longer than 70 chars
        var arena = std.heap.ArenaAllocator.init(base_alloc);
        defer arena.deinit();

        const allocator = arena.allocator();
        var bytes_written: usize = 0;

        bytes_written += try file.write("P3\n");
        {
            const str = std.fmt.allocPrint(allocator, "{} {}\n", .{ self.width, self.height }) catch "0 0\n";
            bytes_written += try file.write(str);
            bytes_written += try file.write("255\n");
        }

        const len = self.width * self.height;
        {
            var i: usize = 0;
            // manually unroll the loop
            while (i + 5 < len) : (i += 5) {
                const one = self.data[i].to32bit();
                const two = self.data[i + 1].to32bit();
                const thr = self.data[i + 2].to32bit();
                const fou = self.data[i + 3].to32bit();
                const fiv = self.data[i + 4].to32bit();

                const str = try std.fmt.allocPrint(allocator, "{} {} {} {} {} {} {} {} {} {} {} {} {} {} {}\n", .{
                    one[0], one[1], one[2],
                    two[0], two[1], two[2],
                    thr[0], thr[1], thr[2],
                    fou[0], fou[1], fou[2],
                    fiv[0], fiv[1], fiv[2],
                });

                bytes_written += try file.write(str);
            }

            while (i < len) : (i += 1) {
                const col = self.data[i].to32bit();
                const str = try std.fmt.allocPrint(allocator, "{} {} {} ", .{ col[0], col[1], col[2] });

                bytes_written += try file.write(str);
            }
        }

        bytes_written += try file.write("\n");

        return bytes_written;
    }
};
