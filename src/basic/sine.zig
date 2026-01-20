const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

pub const GenOptions = struct {
    frequency: f32,
    amplitude: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: u32,
    channels: u16,
};

pub fn gen(
    comptime T: type,
    options: GenOptions,
) Wave(T) {
    const samples: []const T = generate_samples(T, options);
    defer options.allocator.free(samples);

    const result: Wave(T) = Wave(T){
        .samples = samples,
        .allocator = options.allocator,
        .sample_rate = options.sample_rate,
        .channels = options.channels,
    };

    return result;
}

fn generate_samples(
    comptime T: type,
    options: GenOptions,
) []const T {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);
    const radins_per_sec: f32 = options.frequency * 2.0 * std.math.pi;

    var result: []f32 = options.allocator.alloc(f32, options.length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(f32, @floatFromInt(i)) * radins_per_sec / sample_rate) * options.amplitude;
    }

    return result;
}
