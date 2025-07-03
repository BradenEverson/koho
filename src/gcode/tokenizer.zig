//! GCODE Tokenizer that will convert the flat file into a list of commands

const std = @import("std");
const peekable = @import("peekable.zig");

/// All types a GCODE token can have
pub const TokenTag = enum(u16) {
    g_command,
    m_command,
    t_command,

    axis_param,
    param_value,

    integer,
    float,

    comment,
    newline,
    whitespace,

    semicolon,
    paren_open,
    paren_close,
    asterisk,

    variable,
    operator,
    function,
};

/// A GCODE Token - a tag, index into a buffer and length in that buffer
pub const Token = struct {
    tag: TokenTag,
    idx: u32,
    len: u16,
};

/// Attempts to tokenize a GCODE stream into a list of tokens, reporting any errors along the way
pub fn tokenize(stream: []const u8, buf: *std.ArrayList(Token)) !void {
    var len: u16 = 0;
    var idx: u32 = 0;
    var peek = peekable.PeekableIterator(u8){ .buf = stream };

    while (peek.next()) |tok| {
        len = 1;
        const next: TokenTag = switch (tok) {
            'M' => .m_command,
            'G' => .g_command,
            'T' => .t_command,
        };

        const token = Token{
            .tag = next,
            .idx = idx,
            .len = len,
        };

        try buf.append(token);

        idx += 1;
    }
}
