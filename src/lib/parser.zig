const std = @import("std");

const expressions = @import("./expressions.zig");
const tokens = @import("./tokens.zig");

pub const Parser = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  tokens: std.ArrayList(tokens.Token),
  current: usize = 0,

  pub fn init(alc: std.mem.Allocator, tkns: std.ArrayList(tokens.Token)) Self {
    return Self{
      .allocator = alc,
      .tokens = tkns,
    };
  }

  pub fn deinit(_: *Self) void {}

  fn expression(self: *Self) *expressions.Expr {
    return self.equality();
  }

  fn equality(self: *Self) *expressions.Expr {
    var expr = self.comparison();
    const kinds = &.{
      tokens.Kind.bang_equal, tokens.Kind.equal_equal,
    };
    while (self.match(kinds)) {
      const operator = self.previous();
      const right = self.comparison();
      expr = expressions.Expr{
        .binary = .{
          .left = expr,
          .operator = operator,
          .right = right,
        },
      };
    }
    return expr;
  }

  fn comparison(self: *Self) *expressions.Expr {
    var expr = self.term();
    const kinds = &.{
      tokens.Kind.greater, tokens.Kind.greater_equal, tokens.Kind.less, tokens.Kind.less_equal,
    };
    while (self.match(kinds)) {
      const operator = self.previous();
      const right = self.term();
      expr = expressions.Expr{
        .binary = .{
          .left = expr,
          .operator = operator,
          .right = right,
        },
      };
    }
    return expr;
  }

  fn term(self: *Self) *expressions.Expr {
    var expr = self.factor();
    const kinds = &.{
      tokens.Kind.minus, tokens.Kind.plus,
    };
    while (self.match(kinds)) {
      const operator = self.previous();
      const right = self.factor();
      expr = expressions.Expr{
        .binary = .{
          .left = expr,
          .operator = operator,
          .right = right,
        },
      };
    }
    return expr;
  }

  fn factor(self: *Self) *expressions.Expr {
    var expr = self.unary();
    const kinds = &.{
      tokens.Kind.slash, tokens.Kind.star,
    };
    while (self.match(kinds)) {
      const operator = self.previous();
      const right = self.unary();
      expr = expressions.Expr{
        .binary = .{
          .left = expr,
          .operator = operator,
          .right = right,
        },
      };
    }
    return expr;
  }

  fn unary(self: *Self) *expressions.Expr {
    const kinds = &.{
      tokens.Kind.bang, tokens.Kind.minus,
    };
    if (self.match(kinds)) {
      const operator = self.previous();
      const right = self.unary();
      return expressions.Expr{
        .unary = .{
          .operator = operator,
          .right = right,
        },
      };
    }
    return self.primary();
  }

  fn primary(_: *Self) *expressions.Expr {
    return expressions.Expr{
      .literal = .{
        .value = tokens.Literal.nil,
      },
    };
  }

  fn match(self: *Self, kinds: []tokens.Kind) bool {
    for (kinds) |kind| {
      if (self.check(kind)) {
        self.advance();
        return true;
      }
    }
    return false;
  }

  fn check(self: *Self, kind: tokens.Kind) bool {
    if (self.isAtEnd()) return false;
    return self.peek().kind == kind;
  }

  fn advance(self: *Self) tokens.Token {
    if (!self.isAtEnd()) self.current += 1;
    return self.previous();
  }

  fn isAtEnd(self: *Self) bool {
    return self.peek().kind == tokens.Kind.eof;
  }

  fn peek(self: *Self) tokens.Token {
    return self.tokens[self.current];
  }

  fn previous(self: *Self) tokens.Token {
    return self.tokens[self.current - 1];
  }
};

test "init" {
  var tkns = std.ArrayList(tokens.Token).init(std.testing.allocator);
  defer tkns.deinit();
  var parser = Parser.init(std.testing.allocator, tkns);
  defer parser.deinit();
  std.debug.print("{}\n", .{ parser.current });
}

test "" {
}
