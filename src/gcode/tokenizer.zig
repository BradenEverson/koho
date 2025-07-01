//! GCODE Tokenizer that will convert the flat file into a list of commands

const std = @import("std");

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
    _ = stream;
    _ = buf;
}
