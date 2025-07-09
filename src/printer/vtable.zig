//! The VTable of functions for any printer, making our whole shebang modular

const Direction = @import("direction.zig").Direction;

/// Move on the X Axis
move: *const fn (dir: Direction, steps: u16) void,
/// Move the nozzle extruder
move_extruder: *const fn (steps: u16) void,
/// Set the bed's temperature
set_bed_temp: *const fn (deg_f: f32) void,
/// Set the temperature of the nozzle
set_nozzle_temp: *const fn (deg_f: f32) void,
