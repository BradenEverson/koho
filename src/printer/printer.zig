//! All peripherals the printer system needs

const Stepper = @import("../peripherals/stepper.zig");
const Direction = @import("direction.zig").Direction;

curr_x: u16,
curr_y: u16,
curr_z: u16,

dir_x: Direction,
dir_y: Direction,
dir_z: Direction,

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

        .dir_x = undefined,
        .dir_y = undefined,
        .dir_z = undefined,
    };
}

pub fn printer_homed(self: *Self) void {
    self.curr_x = 0;
    self.curr_y = 0;
    self.curr_z = 0;

    self.dir_x = .right;
    self.dir_y = .up;

    // TODO: Still don't know
    self.dir_z = undefined;
}

pub fn goto(self: *Self, x: u16, y: u16) void {
    if (self.curr_x > x) {
        self.move_2d(.left, self.curr_x - x);
    } else {
        self.move_2d(.right, x - self.curr_x);
    }

    if (self.curr_y > y) {
        self.move_2d(.down, self.curr_y - y);
    } else {
        self.move_2d(.up, y - self.curr_y);
    }
}

pub fn move_2d(self: *Self, dir: Direction, steps: u16) void {
    switch (dir) {
        .left, .right => {
            if (self.dir_x != dir) {
                self.x.swap_dir();
                self.dir_x = dir;
            }

            for (0..steps) |_| {
                self.x.step();
            }

            if (dir == .left) {
                self.curr_x -|= steps;
            } else {
                self.curr_x +|= steps;
            }
        },
        .up, .down => {
            if (self.dir_y != dir) {
                self.y.swap_dir();
                self.dir_y = dir;
            }

            for (0..steps) |_| {
                self.y.step();
            }

            if (dir == .down) {
                self.curr_y -|= steps;
            } else {
                self.curr_y +|= steps;
            }
        },
    }
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
