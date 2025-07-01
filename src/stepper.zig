//! Stepper Motor

const std = @import("std");
const c = @cImport({
    @cDefine("USE_HAL_DRIVER", {});
    @cDefine("STM32F446xx", {});
    @cInclude("main.h");
});

const os = @cImport({
    @cInclude("FreeRTOS.h");
    @cInclude("task.h");
});

/// The current direction the stepper is moving
pub const Direction = enum { Clockwise, CounterClockwise };

/// The GPIO Port for the Step control pin
step_port: [*c]c.GPIO_TypeDef,
/// The GPIO pin for the Step control pin
step_pin: u16,

/// The GPIO Port for the direction control pin
dir_port: [*c]c.GPIO_TypeDef,
/// The GPIO pin for the direction control pin
dir_pin: u16,

steps: u64,

// TODO: Find out what defualt direction is
// direction: Direction

const Self = @This();

/// Initializes the stepper motor with respect to the
/// step and direction pins
pub fn init(
    step_port: [*c]c.GPIO_TypeDef,
    step_pin: u16,
    dir_port: [*c]c.GPIO_TypeDef,
    dir_pin: u16,
) Self {
    var stepper: c.GPIO_InitTypeDef = .{
        .Pin = step_pin,
        .Mode = c.GPIO_MODE_OUTPUT_PP,
        .Pull = c.GPIO_NOPULL,
        .Speed = c.GPIO_SPEED_FREQ_HIGH,
    };
    c.HAL_GPIO_Init(step_port, &stepper);

    var dir: c.GPIO_InitTypeDef = .{
        .Pin = dir_pin,
        .Mode = c.GPIO_MODE_OUTPUT_PP,
        .Pull = c.GPIO_NOPULL,
        .Speed = c.GPIO_SPEED_FREQ_HIGH,
    };
    c.HAL_GPIO_Init(dir_port, &dir);

    return Self{
        .step_port = step_port,
        .step_pin = step_pin,
        .dir_port = dir_port,
        .dir_pin = dir_pin,
        .steps = 0,
    };
}

/// Cleans up the pins bound to the stepper motor
pub fn deinit(self: *Self) void {
    c.HAL_GPIO_DeInit(self.dir_port, self.dir_pin);
    c.HAL_GPIO_DeInit(self.step_port, self.step_pin);
}

/// Complete a single step
pub fn step(self: *Self) void {
    if (self.steps % 500 == 0) {
        self.swap_dir();
    }
    c.HAL_GPIO_WritePin(self.step_port, self.step_pin, c.GPIO_PIN_SET);
    os.vTaskDelay(1);
    c.HAL_GPIO_WritePin(self.step_port, self.step_pin, c.GPIO_PIN_RESET);
    os.vTaskDelay(1);
    self.steps += 1;
}

/// Swap the direction we're moving
pub fn swap_dir(self: *Self) void {
    c.HAL_GPIO_TogglePin(self.dir_port, self.dir_pin);
}
