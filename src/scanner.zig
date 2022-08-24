const std = @import("std");

const helpers = @import("./helpers.zig");
const tokens = @import("./tokens.zig");

pub const Scanner = struct {
  const Self = @This();

  source: []const u8,
  tokens: std.ArrayList(tokens.Token),
  start: usize,
  current: usize,
  line: usize,

  pub fn scanTokens(self: *Self) std.ArrayList(tokens.Token) {
    while (!self.isAtEnd()) {
      self.start = self.current;
      self.scanToken();
    }

    // self.tokens.append(tokens.Token{
    //   .kind = .eof,
    //   .lexeme = "",
    //   .literal = null,
    //   .line = self.line,
    // });
    self.addToken(.eof);
    return self.tokens;
  }

  fn scanToken(self: *Self) void {
    const char = self.advance();
    // TODO: unroll into an expression
    switch (char) {
      '(' => addToken(.left_paren),
      ')' => addToken(.right_paren),
      '{' => addToken(.left_brace),
      '}' => addToken(.right_brace),
      ',' => addToken(.comma),
      '.' => addToken(.dot),
      '-' => addToken(.minus),
      '+' => addToken(.plus),
      ';' => addToken(.semicolon),
      '*' => addToken(.star),
      else => {
        helpers.err(self.line, "Unexpected character.");
      }
    }
  }

  fn isAtEnd(self: *Self) bool {
    return self.current >= self.source.len;
  }

  fn advance(self: *Self) u8 {
    const char = self.source[self.current];
    self.current += 1;
    return char;
  }

  fn addToken(self: *Self, kind: .Kind, literal: ?tokens.Literal) void {
    const text = self.source[self.start..self.current];
    self.tokens.append(tokens.Token{
      .kind = kind,
      .lexeme = text,
      .literal = literal,
      .line = self.line,
    });
  }
};
