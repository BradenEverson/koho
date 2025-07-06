//! GCODE Parser - Converts flat token stream to AST

const Token = @import("tokenizer.zig").Token;

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
};
