const std = @import("std");

pub const Token = struct {
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
    @"and", class, @"else", false, fun, @"for", @"if", nil, @"or",
    print, @"return", super, this, true, @"var", @"while",

    eof,
  };

  pub const Literal = struct {
  };

  kind: Kind,
  lexeme: []const u8,
  literal: struct {},
  line: usize,
};

pub const Scanner = struct {
  const Self = @This();

  source: []const u8,
  tokens: std.ArrayList(Token),
  start: usize,
  current: usize,
  line: usize,

  pub fn scanTokens(self: *Self) std.ArrayList(Token) {
    while (!self.isAtEnd()) {
      self.start = self.current;
      self.scanToken();
    }

    self.tokens.addOne(Token{
      .kind = .eof,
      .lexeme = "",
      .literal = null,
      .line = self.line,
    });
    return self.tokens;
  }

  fn scanToken(self: *Self) void {
    const char: u8 = self.advance();
    try std.debug.print("{}\n", .{ char });
  }

  fn isAtEnd(self: *Self) bool {
    return self.current >= self.source.len;
  }

  fn advance(self: *Self) u8 {
    return self.current >= self.source.len;
  }

  fn addToken(self: *Self, kind: Token.Kind, literal: ?Token.Literal) void {
    try std.debug.print("{}{}\n", .{ kind, literal });
    return self.current >= self.source.len;
  }
};
