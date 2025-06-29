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

export fn stepper_task(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (true) {
        c.HAL_GPIO_TogglePin(c.LD2_GPIO_Port, c.LD2_Pin);
        c.HAL_GPIO_WritePin(c.GPIOC, c.GPIO_PIN_9, c.GPIO_PIN_SET);

        c.HAL_GPIO_WritePin(c.GPIOC, c.GPIO_PIN_8, c.GPIO_PIN_SET);
        os.vTaskDelay(1);
        c.HAL_GPIO_WritePin(c.GPIOC, c.GPIO_PIN_8, c.GPIO_PIN_RESET);
        os.vTaskDelay(1);
    }
}

export fn entry() callconv(.c) void {
    var step_pin: c.GPIO_InitTypeDef = .{
        .Pin = c.GPIO_PIN_8,
        .Mode = c.GPIO_MODE_OUTPUT_PP,
        .Pull = c.GPIO_NOPULL,
        .Speed = c.GPIO_SPEED_FREQ_HIGH,
    };
    c.HAL_GPIO_Init(c.GPIOA, &step_pin);

    var dir_pin: c.GPIO_InitTypeDef = .{
        .Pin = c.GPIO_PIN_9,
        .Mode = c.GPIO_MODE_OUTPUT_PP,
        .Pull = c.GPIO_NOPULL,
        .Speed = c.GPIO_SPEED_FREQ_HIGH,
    };
    c.HAL_GPIO_Init(c.GPIOC, &dir_pin);

    // Create FreeRTOS task
    const pvParameters: ?*anyopaque = null;
    const pxCreatedTask: ?*os.TaskHandle_t = null;
    _ = os.xTaskCreate(stepper_task, "stepper", 256, pvParameters, 15, pxCreatedTask);

    os.vTaskStartScheduler();
    unreachable;
}
