pub const Sine = @import("./basic/sine.zig");
pub const Square = @import("./basic/square.zig");
pub const Sawtooth = @import("./basic/sawtooth.zig");

test "Import each module's tests" {
    _ = @import("./basic/square.zig");
    _ = @import("./basic/sine.zig");
    _ = @import("./basic/sawtooth.zig");
}
