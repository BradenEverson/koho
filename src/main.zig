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

const Direction = @import("printer/direction.zig").Direction;

const Stepper = @import("peripherals/stepper.zig");
const Endstop = @import("peripherals/endstop.zig");

const Printer = @import("printer/printer.zig");

const pvParameters: ?*anyopaque = null;
const pxCreatedTask: ?*os.TaskHandle_t = null;

var x_axis: Stepper = undefined;
var y_axis: Stepper = undefined;
var z_axis: Stepper = undefined;
var extruder: Stepper = undefined;

var x_endstop: Endstop = undefined;
var y_endstop: Endstop = undefined;

var printer: Printer = undefined;

export fn draw(params: ?*anyopaque) callconv(.c) void {
    _ = params;
    while (!x_endstop.ready or !y_endstop.ready) {}

    printer.printer_homed();

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

    x_endstop.ready = true;
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

    y_endstop.ready = true;
    os.vTaskDelete(null);
}

export fn EXTI0_IRQHandler() callconv(.c) void {
    x_endstop.callback(&x_endstop);
    c.HAL_GPIO_EXTI_IRQHandler(c.GPIO_PIN_0);
}

export fn EXTI1_IRQHandler() callconv(.c) void {
    y_endstop.callback(&y_endstop);
    c.HAL_GPIO_EXTI_IRQHandler(c.GPIO_PIN_1);
}

export fn entry() callconv(.c) void {
    x_axis = Stepper.init(c.GPIOB, c.GPIO_PIN_8, c.GPIOB, c.GPIO_PIN_9);
    y_axis = Stepper.init(c.GPIOC, c.GPIO_PIN_8, c.GPIOC, c.GPIO_PIN_9);
    z_axis = Stepper.init(c.GPIOC, c.GPIO_PIN_5, c.GPIOC, c.GPIO_PIN_6);
    extruder = Stepper.init(c.GPIOC, c.GPIO_PIN_2, c.GPIOC, c.GPIO_PIN_3);

    x_endstop = Endstop.init(c.GPIOB, c.GPIO_PIN_0, c.EXTI0_IRQn);
    y_endstop = Endstop.init(c.GPIOB, c.GPIO_PIN_1, c.EXTI1_IRQn);

    y_axis.swap_dir();
    x_axis.swap_dir();
    z_axis.swap_dir();

    _ = os.xTaskCreate(home_x_axis, "home the x axis", 256, pvParameters, 15, pxCreatedTask);
    _ = os.xTaskCreate(home_y_axis, "home the y axis", 256, pvParameters, 15, pxCreatedTask);

    printer = Printer.init(x_axis, y_axis, z_axis, extruder);
    _ = os.xTaskCreate(draw, "Draw a pretty picture :)", 256, pvParameters, 15, pxCreatedTask);

    os.vTaskStartScheduler();
    unreachable;
}
