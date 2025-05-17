# ZAlgo

A collection of algorithms implemented in [Zig](https://ziglang.org/).  

Integrate into a Zig project:

```bash
 zig fetch --save https://github.com/marko03kostic/zalgo/archive/VERSION.tar.gz
```

Add to `build.zig`:
```zig
const zalgo = b.dependency("zalgo", .{});

exe.root_module.addImport("zalgo", zalgo.module("zalgo"));
```

Example usage:

```zig
const zalgo = @import("zalgo");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
defer _ = gpa.deinit();


const vertices: usize = 6;
const origin: usize = 0;
var array = try std.ArrayList(struct { source: usize, weight: i8, destination: usize }).initCapacity(allocator, 8);
defer array.deinit();

array.insertAssumeCapacity(0, .{ .source = 0, .destination = 1, .weight = 5 });
array.insertAssumeCapacity(1, .{ .source = 0, .destination = 2, .weight = 7 });
array.insertAssumeCapacity(2, .{ .source = 1, .destination = 2, .weight = 3 });
array.insertAssumeCapacity(3, .{ .source = 1, .destination = 3, .weight = 4 });
array.insertAssumeCapacity(4, .{ .source = 1, .destination = 4, .weight = 6 });
array.insertAssumeCapacity(5, .{ .source = 3, .destination = 4, .weight = -1 });
array.insertAssumeCapacity(6, .{ .source = 3, .destination = 5, .weight = 2 });
array.insertAssumeCapacity(7, .{ .source = 4, .destination = 5, .weight = -3 });

const distances = try zalgo.bellmanFord(allocator, vertices, array.items, origin, i8);
defer distances.deinit();

for (distances.items, 0..) |d, i| {
    std.debug.print("Shortest distance from node {} to node {} is {}\n", .{origin, i, d});
}
```
Output:
```
Shortest distance from node 0 to node 0 is 0
Shortest distance from node 0 to node 1 is 5
Shortest distance from node 0 to node 2 is 7
Shortest distance from node 0 to node 3 is 9
Shortest distance from node 0 to node 4 is 8
Shortest distance from node 0 to node 5 is 5
```
