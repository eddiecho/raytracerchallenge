const std = @import("std");

pub const IntersectionPoint = union(enum) {
    Zero: void,
    One: f32,
    Two: [2]f32,

    const Self = @This();

    pub fn zero() Self {
        return Self{ .Zero = {} };
    }

    pub fn one(p: f32) Self {
        return Self{ .One = p };
    }

    pub fn two(p1: f32, p2: f32) Self {
        return Self{ .Two = .{ p1, p2 } };
    }
};

pub const Intersection = struct {
    points: IntersectionPoint,
    // ideally, this should be an index to some array of shapes
    object_idx: usize,

    const Self = @This();

    pub fn new(points: IntersectionPoint, object_idx: usize) Self {
        return Self{ .points = points, .object_idx = object_idx };
    }

    pub fn hit(points: []const Self) ?Self {
        var ret: Self = null;
        var t: f32 = std.math.inf_f32;

        for (points) |point| {
            switch (point.points) {
                .Zero => continue,
                .One => |p| {
                    if (p > 0 and p < t) {
                        ret = point;
                        t = p;
                    }
                },
                .Two => |ps| {
                    if (ps[0] > 0 and ps[0] < t) {
                        ret = point;
                        t = ps[0];
                    }
                    if (ps[1] > 0 and ps[1] < t) {
                        ret = point;
                        t = ps[1];
                    }
                },
            }
        }

        return ret;
    }
};

// better handling than Intersection directly,
// basically more convenient for some actions i guess
// idk we'll see
pub const Collision = struct {
    object_idx: usize,
    t: f32,

    fn comparator(context: void, lhs: Collision, rhs: Collision) bool {
        _ = context;
        return lhs.t < rhs.t;
    }
};

pub fn sortIntersections(allocator: std.mem.Allocator, xs: std.ArrayList(Intersection)) !std.ArrayList(f32) {
    var ret = std.ArrayList(f32).init(allocator);
    for (xs.items) |x| {
        switch (x.points) {
            .Zero => continue,
            .One => |t| try ret.append(t),
            .Two => |ts| {
                try ret.append(ts[0]);
                try ret.append(ts[1]);
            }
        }
    }

    std.sort.sort(f32, ret.items, {}, comptime std.sort.asc(f32));
    return ret;
}

pub fn sortCollisions(cs: std.ArrayList(Collision)) void {
    std.sort.sort(Collision, cs.items, {}, Collision.comparator);
}
