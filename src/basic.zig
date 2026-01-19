pub const Sine = @import("./basic/sine.zig");
pub const Square = @import("./basic/square.zig");

test "Import each module's tests" {
    _ = @import("./basic/square.zig");
}
