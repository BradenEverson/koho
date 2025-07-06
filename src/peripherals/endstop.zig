//! An endstop + the ability to tie a handler to it's interrupt

const c = @cImport({
    @cDefine("USE_HAL_DRIVER", {});
    @cDefine("STM32F446xx", {});
    @cInclude("main.h");
});

const os = @cImport({
    @cInclude("FreeRTOS.h");
    @cInclude("task.h");
});

/// The GPIO Port for the Step control pin
port: [*c]c.GPIO_TypeDef,
/// The GPIO pin for the Step control pin
pin: u16,
/// If the endstop has been triggered
triggered: bool,

const Self = @This();

pub fn init(port: [*c]c.GPIO_TypeDef, pin: u16, irq_n: c_int) Self {
    var es: c.GPIO_InitTypeDef = .{
        .Pin = pin,
        .Mode = c.GPIO_MODE_IT_FALLING,
        .Pull = c.GPIO_PULLUP,
    };

    c.HAL_GPIO_Init(port, &es);
    c.HAL_NVIC_SetPriority(irq_n, 0, 0);
    c.HAL_NVIC_EnableIRQ(irq_n);

    return Self{
        .port = port,
        .pin = pin,
        .triggered = false,
    };
}

pub fn callback(self: *Self) void {
    self.triggered = true;
}
