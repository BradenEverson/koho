//! GCODE AST Executor

const ptable = @import("../printer/vtable.zig");
const Expr = @import("parser.zig").Expr;

vtable: ptable,

const Self = @This();

pub fn init(vtable: ptable) Self {
    return Self{
        .vtable = vtable,
    };
}

pub fn exec(self: *Self, gcode: []Expr) !void {
    _ = self;
    _ = gcode;
}
