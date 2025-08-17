//! # Mika
//!
//! 73.416 ~ 246.942
//! D2 ~ B3

const std = @import("std");
const lightmix = @import("lightmix");

const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

pub const GenerateOptions = struct {
    frequency: f32,
    amplitude: f32,
    length: usize,
    allocator: std.mem.Allocator,

    sample_rate: usize,
    channels: usize,
    bits: usize,
};

pub fn generate(options: GenerateOptions) Wave {
    const sample_rate: f32 = @floatFromInt(options.sample_rate);

    const base_data: []const f32 = generate_data(options.frequency, options.amplitude, options.length, sample_rate, options.allocator);
    defer options.allocator.free(base_data);
    const base: Wave = Wave.init(base_data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });

    const base_one_second_frequency: f32 = options.frequency / 2;
    const base_one_second_data: []const f32 = generate_data(base_one_second_frequency, options.amplitude, options.length, sample_rate, options.allocator);
    const base_one_second: Wave = Wave.init(base_one_second_data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer base_one_second.deinit();

    const first_result: Wave = base.mix(base_one_second) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("Failed to generate synth hoge");
    };

    const base_one_fourth_frequency: f32 = options.frequency / 2;
    const base_one_fourth_data: []const f32 = generate_data(base_one_fourth_frequency, options.amplitude, options.length, sample_rate, options.allocator);
    const base_one_fourth: Wave = Wave.init(base_one_fourth_data, options.allocator, .{
        .sample_rate = options.sample_rate,
        .channels = options.channels,
        .bits = options.bits,
    });
    defer base_one_fourth.deinit();

    const result: Wave = first_result.mix(base_one_fourth) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("Failed to generate synth hoge");
    };

    return result;
}

fn generate_data(frequency: f32, amplitude: f32, length: usize, sample_rate: f32, allocator: std.mem.Allocator) []const f32 {
    const radins_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(f32, @floatFromInt(i)) * radins_per_sec / sample_rate) * amplitude;
    }

    return result;
}
