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

const Stepper = @import("stepper.zig");

var stepper: Stepper = undefined;

export fn stepper_task(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (true) {
        stepper.step();
    }
}

export fn entry() callconv(.c) void {
    stepper = Stepper.init(c.GPIOC, c.GPIO_PIN_8, c.GPIOC, c.GPIO_PIN_9);

    // Create FreeRTOS task
    const pvParameters: ?*anyopaque = null;
    const pxCreatedTask: ?*os.TaskHandle_t = null;
    _ = os.xTaskCreate(stepper_task, "stepper", 256, pvParameters, 15, pxCreatedTask);

    os.vTaskStartScheduler();
    unreachable;
}
