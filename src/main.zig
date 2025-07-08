//! Zig Entrypoint

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

const Stepper = @import("peripherals/stepper.zig");
const Endstop = @import("peripherals/endstop.zig");

const Printer = @import("printer/printer.zig");

const pvParameters: ?*anyopaque = null;
const pxCreatedTask: ?*os.TaskHandle_t = null;

var x_axis: Stepper = undefined;
var y_axis: Stepper = undefined;

var x_endstop: Endstop = undefined;
var y_endstop: Endstop = undefined;

export fn draw(params: ?*anyopaque) callconv(.c) void {
    _ = params;
    while (!x_endstop.triggered and !y_endstop.triggered) {}

    for (0..750) |_| {
        x_axis.step();
        y_axis.step();
    }

    for (0..250) |_| {
        y_axis.step();
    }

    x_axis.swap_dir();
    for (0..250) |_| {
        x_axis.step();
    }

    y_axis.swap_dir();
    for (0..500) |_| {
        y_axis.step();
    }

    x_axis.swap_dir();
    for (0..500) |_| {
        x_axis.step();
    }

    y_axis.swap_dir();
    for (0..500) |_| {
        y_axis.step();
    }

    x_axis.swap_dir();
    for (0..250) |_| {
        x_axis.step();
    }

    y_axis.swap_dir();
    for (0..250) |_| {
        y_axis.step();
    }

    while (true) {}
}

export fn home_x_axis(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (!x_endstop.triggered) {
        x_axis.step();
    }

    x_axis.swap_dir();
    for (0..100) |_| {
        x_axis.step();
    }

    os.vTaskDelete(null);
}

export fn home_y_axis(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (!y_endstop.triggered) {
        y_axis.step();
    }

    y_axis.swap_dir();
    for (0..50) |_| {
        y_axis.step();
    }

    os.vTaskDelete(null);
}

var x_last_trigger_time: u32 = 0;
export fn EXTI0_IRQHandler() callconv(.c) void {
    const now = c.HAL_GetTick();
    if (now - x_last_trigger_time > 5) {
        x_endstop.triggered = true;
        x_last_trigger_time = now;
    }
    c.HAL_GPIO_EXTI_IRQHandler(c.GPIO_PIN_0);
}

var y_last_trigger_time: u32 = 0;
export fn EXTI1_IRQHandler() callconv(.c) void {
    const now = c.HAL_GetTick();
    if (now - y_last_trigger_time > 5) {
        y_endstop.triggered = true;
        y_last_trigger_time = now;
    }
    c.HAL_GPIO_EXTI_IRQHandler(c.GPIO_PIN_1);
}

export fn entry() callconv(.c) void {
    x_axis = Stepper.init(c.GPIOB, c.GPIO_PIN_8, c.GPIOB, c.GPIO_PIN_9);
    y_axis = Stepper.init(c.GPIOC, c.GPIO_PIN_8, c.GPIOC, c.GPIO_PIN_9);

    x_endstop = Endstop.init(c.GPIOB, c.GPIO_PIN_0, c.EXTI0_IRQn);
    y_endstop = Endstop.init(c.GPIOB, c.GPIO_PIN_1, c.EXTI1_IRQn);

    y_axis.swap_dir();
    x_axis.swap_dir();

    _ = os.xTaskCreate(home_x_axis, "home the x axis", 256, pvParameters, 15, pxCreatedTask);
    _ = os.xTaskCreate(home_y_axis, "home the y axis", 256, pvParameters, 15, pxCreatedTask);

    _ = os.xTaskCreate(draw, "Draw a pretty picture :)", 256, pvParameters, 10, pxCreatedTask);

    os.vTaskStartScheduler();
    unreachable;
}
