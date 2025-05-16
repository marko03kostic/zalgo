const std = @import("std");

pub fn bellmanFord(
    allocator: std.mem.Allocator,
    vertices: usize,
    iterable: anytype,
    source: usize,
    comptime T: type,
) error{ NegativeCycle, OutOfMemory }!std.ArrayList(T) {
    var dist = try std.ArrayList(T).initCapacity(allocator, vertices);

    dist.insertAssumeCapacity(source, 0);

    for (1..vertices) |i| {
        dist.insertAssumeCapacity(i, std.math.maxInt(T));
    }

    for (0..vertices) |_| {
        for (iterable) |e| {
            if (dist.items[e.source] != std.math.maxInt(T) and
                dist.items[e.source] + e.weight < dist.items[e.destination])
            {
                dist.items[e.destination] = dist.items[e.source] + e.weight;
            }
        }
    }

    for (iterable) |e| {
        if (dist.items[e.source] != std.math.maxInt(T) and
            dist.items[e.source] + e.weight < dist.items[e.destination])
        {
            dist.deinit();
            return error.NegativeCycle;
        }
    }

    return dist;
}

test "finds shortest path" {
    const vertices: usize = 6;
    var array = try std.ArrayList(struct { source: usize, weight: i8, destination: usize }).initCapacity(std.testing.allocator, 8);
    defer array.deinit();

    array.insertAssumeCapacity(0, .{ .source = 0, .destination = 1, .weight = 5 });
    array.insertAssumeCapacity(1, .{ .source = 0, .destination = 2, .weight = 7 });
    array.insertAssumeCapacity(2, .{ .source = 1, .destination = 2, .weight = 3 });
    array.insertAssumeCapacity(3, .{ .source = 1, .destination = 3, .weight = 4 });
    array.insertAssumeCapacity(4, .{ .source = 1, .destination = 4, .weight = 6 });
    array.insertAssumeCapacity(5, .{ .source = 3, .destination = 4, .weight = -1 });
    array.insertAssumeCapacity(6, .{ .source = 3, .destination = 5, .weight = 2 });
    array.insertAssumeCapacity(7, .{ .source = 4, .destination = 5, .weight = -3 });

    const distances = try bellmanFord(std.testing.allocator, vertices, array.items, 0, i8);
    defer distances.deinit();

    var expectedDistances = try std.ArrayList(i8).initCapacity(std.testing.allocator, vertices);
    defer expectedDistances.deinit();

    expectedDistances.insertAssumeCapacity(0, 0);
    expectedDistances.insertAssumeCapacity(1, 5);
    expectedDistances.insertAssumeCapacity(2, 7);
    expectedDistances.insertAssumeCapacity(3, 9);
    expectedDistances.insertAssumeCapacity(4, 8);
    expectedDistances.insertAssumeCapacity(5, 5);

    try std.testing.expectEqualDeep(expectedDistances, distances);
}

test "detects negative cycle" {
    const vertices: usize = 3;
    var edges = try std.ArrayList(struct { source: usize, destination: usize, weight: i8 }).initCapacity(std.testing.allocator, 3);
    defer edges.deinit();

    edges.insertAssumeCapacity(0, .{ .source = 0, .destination = 1, .weight = 1 });
    edges.insertAssumeCapacity(1, .{ .source = 1, .destination = 2, .weight = -1 });
    edges.insertAssumeCapacity(2, .{ .source = 2, .destination = 0, .weight = -1 });

    const result = bellmanFord(std.testing.allocator, vertices, edges.items, 0, i8);
    try std.testing.expectError(error.NegativeCycle, result);
}
