const std = @import("std");

pub const Token = struct {
  kind: Kind,
  lexeme: []const u8,
  literal: Literal,
  line: usize,
};

// TODO: move inside Token
pub const Literal = union(enum) {
  nil,
  boolean: bool,
  number: f64,
  identifier: []const u8,
  string: []const u8,
};

// TODO: move inside Token
pub const Kind = enum {
  // 1 char
  left_paren, right_paren,
  left_brace, right_brace,
  comma, dot, minus, plus, semicolon, slash, star,

  // 1-2 char
  bang, bang_equal,
  equal, equal_equal,
  greater, greater_equal,
  less, less_equal,

  // literals
  identifier, string, number,

  // keywords
  @"and", @"class", @"else", @"false", @"fun", @"for", @"if", @"nil", @"or",
  @"print", @"return", @"super", @"this", @"true", @"var", @"while",

  eof,
};

// TODO: move inside Token
pub const keywords = [_]Kind{
  .@"and", .@"class", .@"else", .@"false", .@"fun", .@"for", .@"if", .@"nil", .@"or",
  .@"print", .@"return", .@"super", .@"this", .@"true", .@"var", .@"while",
};

test "" {
}
