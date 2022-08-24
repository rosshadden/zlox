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
    while (!isAtEnd()) {
      self.start = self.current;
      scanToken();
    }

    // self.tokens.append(tokens.Token{
    //   .kind = .eof,
    //   .lexeme = "",
    //   .literal = null,
    //   .line = self.line,
    // });
    addToken(.eof);
    return self.tokens;
  }

  fn scanToken(self: *Self) void {
    const char = advance();
    // TODO: unroll into an expression
    switch (char) {
      // 1 char
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

      // 2 char
      '!' => addToken(if (match('=')) .bang_equal else .bang),
      '=' => addToken(if (match('=')) .equal_equal else .equal),
      '<' => addToken(if (match('=')) .less_equal else .less),
      '>' => addToken(if (match('=')) .greater_equal else .greater),
      '/' => {
        if (match('/')) {
          while (peek() != '\n' and !isAtEnd()) advance();
        } else {
          addToken(.slash);
        }
      },

      // whitespace
      ' ', '\r', '\t' => {},
      '\n' => {
        self.line += 1;
      },

      else => {
        helpers.err(self.line, "Unexpected character.");
      }
    }
  }

  fn match(self: *Self, expected: u8) bool {
    if (isAtEnd()) return false;
    if (self.source[self.current] != expected) return false;

    self.current += 1;
    return true;
  }

  fn peek(self: *Self) u8 {
    if (isAtEnd()) return null;
    return self.source[self.current];
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
