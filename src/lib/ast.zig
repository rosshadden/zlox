const std = @import("std");

const expressions = @import("./expressions.zig");
const tokens = @import("./tokens.zig");

fn paren(w: anytype, name: []const u8, exprs: []const *const expressions.Expr) error{OutOfMemory}!void {
  try w.print("(", .{});
  try w.print("{s}", .{ name });
  for (exprs) |expr| {
    try w.print(" ", .{});
    try printAst(w, expr.*);
  }
  try w.print(")", .{});
}

pub fn printAst(w: anytype, expr: *expressions.Expr) !void {
  switch (expr.*) {
    .binary => {
      try paren(w, expr.binary.operator.lexeme, &.{ expr.binary.left, expr.binary.right });
    },
    .grouping => {
      try paren(w, "group", &.{ expr.grouping.expression });
    },
    .literal => {
      switch (expr.literal.value) {
        .nil => {
          try w.print("nil", .{});
        },
        .boolean => {
          try w.print("{}", .{ expr.literal.value.boolean });
        },
        .number => {
          try w.print("{d}", .{ expr.literal.value.number });
        },
        .identifier => {
          try w.print("{s}", .{ expr.literal.value.identifier });
        },
        .string => {
          try w.print("\"{s}\"", .{ expr.literal.value.string });
        },
      }
    },
    .unary => {
      try paren(w, expr.unary.operator.lexeme, &.{ expr.unary.right });
    },
  }
}

test "paren empty" {
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try paren(result.writer(), "foo", &.{});
  try std.testing.expect(std.mem.eql(u8, result.items, "(foo)"));
}

test "paren nil" {
  const expr = expressions.Expr{
    .literal = .{
      .value = tokens.Literal.nil,
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try paren(result.writer(), "foo", &.{ &expr });
  try std.testing.expect(std.mem.eql(u8, result.items, "(foo nil)"));
}

test "ast literal nil" {
  const expr = expressions.Expr{
    .literal = .{
      .value = tokens.Literal.nil,
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "nil"));
}

test "ast literal string" {
  const expr = expressions.Expr{
    .literal = .{
      .value = .{
        .string = "lol",
      },
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "\"lol\""));
}

test "ast literal number" {
  const expr = expressions.Expr{
    .literal = .{
      .value = .{
        .number = 4,
      },
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "4"));
}

test "ast unary" {
  const lit = expressions.Expr{
    .literal = .{
      .value = .{
        .number = 4,
      },
    },
  };
  const expr = expressions.Expr{
    .unary = .{
      .operator = .{
        .kind = tokens.Kind.minus,
        .lexeme = "-",
        .literal = tokens.Literal.nil,
        .line = 1,
      },
      .right = &lit,
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "(- 4)"));
}

test "ast binary" {
  const lit = expressions.Expr{
    .literal = .{
      .value = .{
        .number = 4,
      },
    },
  };
  const expr = expressions.Expr{
    .binary = .{
      .left = &lit,
      .operator = .{
        .kind = tokens.Kind.equal_equal,
        .lexeme = "==",
        .literal = tokens.Literal.nil,
        .line = 1,
      },
      .right = &lit,
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "(== 4 4)"));
}

test "ast grouping" {
  const lit = expressions.Expr{
    .literal = .{
      .value = .{
        .number = 4,
      },
    },
  };
  const expr = expressions.Expr{
    .grouping = .{
      .expression = &lit,
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "(group 4)"));
}

test "main" {
  const expr = expressions.Expr{
    .binary = .{
      .left = &expressions.Expr{
        .unary = expressions.UnaryExpr{
          .operator = .{
            .kind = tokens.Kind.minus,
            .lexeme = "-",
            .literal = tokens.Literal.nil,
            .line = 1,
          },
          .right = &expressions.Expr{
            .literal = .{
              .value = .{
                .number = 123,
              },
            },
          },
        },
      },
      .operator = .{
        .kind = tokens.Kind.star,
        .lexeme = "*",
        .literal = tokens.Literal.nil,
        .line = 1,
      },
      .right = &expressions.Expr{
        .grouping = .{
          .expression = &expressions.Expr{
            .literal = .{
              .value = .{
                .number = 45.67,
              },
            },
          },
        },
      },
    },
  };
  var result = std.ArrayList(u8).init(std.testing.allocator);
  defer result.deinit();
  try printAst(result.writer(), expr);
  try std.testing.expect(std.mem.eql(u8, result.items, "(* (- 123) (group 45.67))"));
}

test "" {
}
