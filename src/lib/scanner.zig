const std = @import("std");

const helpers = @import("./helpers.zig");
const tokens = @import("./tokens.zig");

pub const Scanner = struct {
  const Self = @This();

  source: []const u8,
  allocator: std.mem.Allocator,
  tokens: std.ArrayList(tokens.Token),
  start: usize = 0,
  current: usize = 0,
  line: usize = 0,

  pub fn init(allocator: std.mem.Allocator, source: []const u8) Scanner {
    return Scanner{
      .source = source,
      .allocator = allocator,
      .tokens = std.ArrayList(tokens.Token).init(allocator),
    };
  }

  pub fn deinit(self: *Self) void {
    self.tokens.deinit();
  }

  pub fn scanTokens(self: *Self) ![]const tokens.Token {
    while (!self.isAtEnd()) {
      self.start = self.current;
      try self.scanToken();
    }

    try self.addToken(.eof);
    return self.tokens.toOwnedSlice();
  }

  fn scanToken(self: *Self) !void {
    const char = self.advance();
    // TODO: unroll into an expression
    switch (char) {
      // 1 char
      '(' => try self.addToken(.left_paren),
      ')' => try self.addToken(.right_paren),
      '{' => try self.addToken(.left_brace),
      '}' => try self.addToken(.right_brace),
      ',' => try self.addToken(.comma),
      '.' => try self.addToken(.dot),
      '-' => try self.addToken(.minus),
      '+' => try self.addToken(.plus),
      ';' => try self.addToken(.semicolon),
      '*' => try self.addToken(.star),

      // 2 char
      '!' => try self.addToken(if (self.match('=')) .bang_equal else .bang),
      '=' => try self.addToken(if (self.match('=')) .equal_equal else .equal),
      '<' => try self.addToken(if (self.match('=')) .less_equal else .less),
      '>' => try self.addToken(if (self.match('=')) .greater_equal else .greater),
      '/' => {
        if (self.match('/')) {
          // a comment goes until the end of the line, pal
          while (self.peek() != '\n' and !self.isAtEnd()) _ = self.advance();
        } else {
          try self.addToken(.slash);
        }
      },

      // whitespace
      ' ', '\r', '\t' => {},
      '\n' => {
        self.line += 1;
      },

      // woke literals
      '"' => try self.string(),
      '0'...'9' => try self.number(),
      'a'...'z', 'A'...'Z', '_' => try self.identifier(),

      else => {
        helpers.err(self.line, "Unexpected character.");
      }
    }
  }

  fn identifier(self: *Self) !void {
    while (isAlphaNumeric(self.peek())) _ = self.advance();

    // TODO: abstract getting current lexeme
    const text = self.source[self.start .. self.current];
    const kind: tokens.Kind = identifierType(text);
    try self.addTokenLiteral(kind, tokens.Literal{ .identifier = text });
  }

  fn number(self: *Self) !void {
    while (std.ascii.isDigit(self.peek())) _ = self.advance();

    // look for a fractional part
    if (self.peek() == '.' and std.ascii.isDigit(self.peek2())) {
      // consume the '.'
      _ = self.advance();

      while (std.ascii.isDigit(self.peek())) _ = self.advance();
    }

    const value = try std.fmt.parseFloat(f64, self.source[self.start .. self.current]);
    try self.addTokenLiteral(.number, tokens.Literal{ .number = value });
  }

  fn string(self: *Self) !void {
    while (self.peek() != '"' and !self.isAtEnd()) {
      // multiline strings
      if (self.peek() == '\n') self.line += 1;
      _ = self.advance();
    }

    if (self.isAtEnd()) {
      helpers.err(self.line, "Unterminated string.");
      return;
    }

    // the closing '"'
    _ = self.advance();

    // trim the sourrounding quotes
    const value = self.source[self.start + 1 .. self.current - 1];
    try self.addTokenLiteral(.string, tokens.Literal{ .string = value });
  }

  fn match(self: *Self, expected: u8) bool {
    if (self.isAtEnd()) return false;
    if (self.source[self.current] != expected) return false;

    self.current += 1;
    return true;
  }

  fn peek(self: *Self) u8 {
    if (self.isAtEnd()) return 0;
    return self.source[self.current];
  }

  fn peek2(self: *Self) u8 {
    if (self.current + 1 >= self.source.len) return 0;
    return self.source[self.current + 1];
  }

  fn isAtEnd(self: *Self) bool {
    return self.current >= self.source.len;
  }

  fn advance(self: *Self) u8 {
    const char = self.source[self.current];
    self.current += 1;
    return char;
  }

  fn addToken(self: *Self, kind: tokens.Kind) !void {
    try self.addTokenLiteral(kind, .nil);
  }

  fn addTokenLiteral(self: *Self, kind: tokens.Kind, literal: tokens.Literal) !void {
    const text = self.source[self.start .. self.current];
    try self.tokens.append(tokens.Token{
      .kind = kind,
      .lexeme = text,
      .literal = literal,
      .line = self.line,
    });
  }

  fn identifierType(value: []const u8) tokens.Kind {
    for (tokens.keywords) |key| {
      if (key == std.meta.stringToEnum(tokens.Kind, value)) return key;
    }
    return .identifier;
  }

  fn isAlphaNumeric(char: u8) bool {
    return std.ascii.isAlNum(char) or char == '_';
  }
};

test "scanner.init" {
  var scanner = Scanner.init(std.testing.allocator, "");
  defer scanner.deinit();
}

test "scanner.scanTokens" {
  var scanner = Scanner.init(std.testing.allocator, "");
  defer scanner.deinit();

  const tok = try scanner.scanTokens();
  defer std.testing.allocator.free(tok);
}

test "" {
}
