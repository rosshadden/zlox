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
    const expr = self.comparison();
    return expr;
  }

  fn comparison(self: *Self) *expressions.Expr {
    const expr = self.term();
    return expr;
  }

  fn term(self: *Self) *expressions.Expr {
    const expr = self.factor();
    return expr;
  }

  fn factor(self: *Self) *expressions.Expr {
    const expr = self.unary();
    return expr;
  }

  fn unary(self: *Self) *expressions.Expr {
    const expr = self.primary();
    return expr;
  }

  fn primary(_: *Self) *expressions.Expr {
    return expressions.Expr{
      .literal = .{
        .value = tokens.Literal.nil,
      },
    };
  }

  fn match(_: *Self) bool {
    return false;
  }

  fn check(_: *Self) bool {
    return false;
  }

  fn advance(_: *Self) void {
  }

  fn isAtEnd(_: *Self) bool {
    return true;
  }

  fn peek(_: *Self) void {
  }

  fn previous(_: *Self) void {
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
