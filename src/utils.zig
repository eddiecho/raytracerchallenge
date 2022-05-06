const std = @import("std");

const EPSILON = 0.00001;

pub fn xor(a: bool, b: bool) bool {
  return a != b;
}

pub fn f32_equals(a: f32, b: f32) bool {
  return std.math.approxEqAbs(f32, a, b, EPSILON);
}
