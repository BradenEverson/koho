//! GCODE Parser - Converts flat token stream to AST

const Token = @import("tokenizer.zig").Token;
const std = @import("std");

pub const Expr = union(enum) {};

pub const Parser = struct {
    stream: []Token,
    cursor: u32,

    pub fn init(tokens: []Token) Parser {
        return Parser{
            .stream = tokens,
            .cursor = 0,
        };
    }

    pub fn parse(self: *Parser, exprs: *std.ArrayList(Expr)) !void {
        _ = self;
        _ = exprs;
    }
};
