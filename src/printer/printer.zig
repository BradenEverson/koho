//! All peripherals the printer system needs

const Stepper = @import("stepper.zig");

/// X-Axis Stepper Motor
x: Stepper,
/// Y-Axis Stepper Motor
y: Stepper,
/// Z-Axis Stepper Motor
z: Stepper,
/// Filament Feeder Stepper Motor
feed: Stepper,

// TODO: Every other part of a 3D Printer

const Self = @This();

pub fn init(x: Stepper, y: Stepper, z: Stepper, feed: Stepper) Self {
    Self{
        .x = x,
        .y = y,
        .z = z,
        .feed = feed,
    };
}
