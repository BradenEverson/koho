//! The VTable of functions for any printer, making our whole shebang modular

/// Move on the X Axis
move_x: *const fn (dir: u8, steps: u32) void,
/// Move on the Y Axis
move_y: *const fn (dir: u8, steps: u32) void,
/// Move on the Z Axis
move_z: *const fn (dir: u8, steps: u32) void,
/// Move the nozzle extruder
move_extruder: *const fn (steps: u32) void,
/// Set the bed's temperature
set_bed_temp: *const fn (deg_f: f32) void,
/// Set the temperature of the nozzle
set_nozzle_temp: *const fn (deg_f: f32) void,
