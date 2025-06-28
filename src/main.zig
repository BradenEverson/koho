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

export fn zig_task(params: ?*anyopaque) callconv(.c) void {
    _ = params;

    while (true) {
        c.HAL_GPIO_TogglePin(c.LD2_GPIO_Port, c.LD2_Pin);
        os.vTaskDelay(100);
    }
}

export fn zigEntrypoint() callconv(.c) void {

    // Temporary task to initialize the system
    const pvParameters: ?*anyopaque = null;
    const pxCreatedTask: ?*os.TaskHandle_t = null;
    _ = os.xTaskCreate(zig_task, "Blinky", 256, pvParameters, 15, pxCreatedTask);
    // Start application
    os.vTaskStartScheduler();

    unreachable;
}

// Custom debug Panic implementation that will be used to print on UART.
pub const panic = std.debug.FullPanic(myPanic);

fn myPanic(msg: []const u8, first_trace_addr: ?usize) noreturn {
    // `_disable_irq()` is demoted to extern but don't work. Maybe because it is was a "static inline" function. Need investigation
    asm volatile ("cpsid i" ::: "memory");

    //Start printing, ensure error is impossible or ignore it. We are already on an error state.
    _ = msg;
    _ = first_trace_addr;
    while (true) {}
}
