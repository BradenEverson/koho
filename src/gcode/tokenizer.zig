//! GCODE Tokenizer that will convert the flat file into a list of commands

const Token = @import("tokens.zig").Token;
const TokenTag = @import("tokens.zig").TokenTag;

buf: []const u8,
