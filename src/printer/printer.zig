//! All peripherals the printer system needs

const Stepper = @import("../peripherals/stepper.zig");

curr_x: u64,
curr_y: u64,
curr_z: u64,

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

/// Creates a new printer system
pub fn init(x: Stepper, y: Stepper, z: Stepper, feed: Stepper) Self {
    return Self{
        .x = x,
        .y = y,
        .z = z,
        .feed = feed,

        // We don't know where we are until we zero the axis
        .curr_x = undefined,
        .curr_y = undefined,
        .curr_z = undefined,
    };
}

/// Homes all axis
pub fn zero(self: *Self) void {
    // TODO: Actually move the steppers until they all hit
    // endstops, causing an interrupt that should set some
    // flag or something

    self.curr_x = 0;
    self.curr_y = 0;
    self.curr_z = 0;
}
