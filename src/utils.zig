const std = @import("std");

const EPSILON = 0.00001;

pub fn xor(a: bool, b: bool) bool {
  return a != b;
}

pub fn f32_equals(a: f32, b: f32) bool {
  return std.math.approxEqAbs(f32, a, b, EPSILON);
}

pub fn debugPrintStruct(obj: anytype) anyerror!void {
  std.debug.print("{s}\n", .{
    @typeName(@TypeOf(obj))
  });

  inline for (std.meta.fields(@TypeOf(obj))) |field| {
    std.debug.print("\t{s} = {any}\n", .{
      field.name,
      @field(obj, field.name),
    });
  }
}

pub fn readFile(filename: []const u8) anyerror![:0]const u8 {
  var file = try std.fs.cwd().openFile(filename, .{.mode = .read_only});
  defer file.close();

  var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
  var file_info = try file.stat();

  const ret = try file.readToEndAlloc(gpa.allocator(), file_info.size + 1);
  ret[file_info.size] = 0;

  return @ptrCast([:0]const u8, ret);
}
