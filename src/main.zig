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

var stepper: Stepper = undefined;
var endstop: Endstop = undefined;

export fn stepper_task(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (!endstop.triggered) {
        stepper.step();
    }
}

export fn EXTI1_IRQHandler() callconv(.c) void {
    c.HAL_GPIO_TogglePin(c.LD2_GPIO_Port, c.LD2_Pin);
    endstop.triggered = true;
}

export fn entry() callconv(.c) void {
    stepper = Stepper.init(c.GPIOC, c.GPIO_PIN_8, c.GPIOC, c.GPIO_PIN_9);
    endstop = Endstop.init(c.GPIOB, c.GPIO_PIN_1, c.EXTI1_IRQn);
    stepper.swap_dir();

    const pvParameters: ?*anyopaque = null;
    const pxCreatedTask: ?*os.TaskHandle_t = null;
    _ = os.xTaskCreate(stepper_task, "stepper", 256, pvParameters, 15, pxCreatedTask);

    os.vTaskStartScheduler();
    unreachable;
}
