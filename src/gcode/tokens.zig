//! Token and TokenTag enums

pub const TokenTag = enum(u16) {};

pub const Token = struct {
    tag: TokenTag,
    idx: u32,
    len: u16,
};
