const std = @import("std");

pub const Basic = @import("./basic.zig");

test "Import each module's tests" {
    _ = @import("./basic.zig");
}
