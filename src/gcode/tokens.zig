//! Token and TokenTag enums

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

pub const Token = struct {
    tag: TokenTag,
    idx: u32,
    len: u16,
};
