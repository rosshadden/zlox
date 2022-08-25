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
      // 1 char
      '(' => self.addToken(.left_paren),
      ')' => self.addToken(.right_paren),
      '{' => self.addToken(.left_brace),
      '}' => self.addToken(.right_brace),
      ',' => self.addToken(.comma),
      '.' => self.addToken(.dot),
      '-' => self.addToken(.minus),
      '+' => self.addToken(.plus),
      ';' => self.addToken(.semicolon),
      '*' => self.addToken(.star),

      // 2 char
      '!' => self.addToken(if (self.match('=')) .bang_equal else .bang),
      '=' => self.addToken(if (self.match('=')) .equal_equal else .equal),
      '<' => self.addToken(if (self.match('=')) .less_equal else .less),
      '>' => self.addToken(if (self.match('=')) .greater_equal else .greater),
      '/' => {
        if (self.match('/')) {
          // a comment goes until the end of the line, pal
          while (self.peek() != '\n' and !self.isAtEnd()) self.advance();
        } else {
          self.addToken(.slash);
        }
      },

      // whitespace
      ' ', '\r', '\t' => {},
      '\n' => {
        self.line += 1;
      },

      // woke literals
      '"' => self.string(),
      '0'...'9' => self.number(),
      'a'...'z', 'A'...'Z', '_' => self.identifier(),

      else => {
        helpers.err(self.line, "Unexpected character.");
      }
    }
  }

  fn identifier(self: *Self) void {
    while (isAlphaNumeric(self.peek())) self.advance();
    self.addToken(.identifier);
  }

  fn number(self: *Self) void {
    while (std.ascii.isDigit(peek())) self.advance();

    // look for a fractional part
    if (self.peek() == '.' and std.ascii.isDigit(self.peekNext())) {
      // consume the '.'
      self.advance();

      while (std.ascii.isDigit(peek())) self.advance();
    }

    const value = std.fmt.parseFloat(f64, self.source[self.start .. self.current]);
    self.addToken(.number, value);
  }

  fn string(self: *Self) void {
    while (self.peek() != '"' and !self.isAtEnd()) {
      // multiline strings
      if (self.peek() == '\n') self.line += 1;
      self.advance();
    }

    if (self.isAtEnd()) {
      helpers.err(self.line, "Unterminated string.");
      return;
    }

    // the closing '"'
    self.advance();

    // trim the sourrounding quotes
    const value = self.source[self.start + 1 .. self.current - 1];
    self.addToken(.string, value);
  }

  fn match(self: *Self, expected: u8) bool {
    if (self.isAtEnd()) return false;
    if (self.source[self.current] != expected) return false;

    self.current += 1;
    return true;
  }

  fn peek(self: *Self) u8 {
    if (self.isAtEnd()) return null;
    return self.source[self.current];
  }

  fn peekNext(self: *Self) u8 {
    if (self.current + 1 >= self.source.len) return null;
    return self.source[self.current + 1];
  }

  fn isAlphaNumeric(char: u8) bool {
    return std.ascii.isAlNum(char) or char == '_';
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
    const text = self.source[self.start .. self.current];
    self.tokens.append(tokens.Token{
      .kind = kind,
      .lexeme = text,
      .literal = literal,
      .line = self.line,
    });
  }
};
