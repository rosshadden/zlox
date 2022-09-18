const std = @import("std");

const expressions = @import("./expressions.zig");
const tokens = @import("./tokens.zig");

fn paren(w: anytype, name: []const u8, exprs: []const *const expressions.Expr) !void {
  try w.print("(", .{});
  try w.print("{s}", .{ name });
  for (exprs) |expr| {
    try w.print(" ", .{});
    try printAst(w, expr.*);
  }
  try w.print(")", .{});
}

pub fn printAst(w: anytype, expr: expressions.Expr) !void {
  switch (expr) {
    .binary => {},
    .grouping => {},
    .literal => {
      switch (expr.literal.value) {
        .nil => {
          try w.print("nil", .{});
        },
        .identifier => {
          try w.print("{s}", .{ expr.literal.value.identifier });
        },
        .string => {
          try w.print("{s}", .{ expr.literal.value.string });
        },
        .number => {
          try w.print("{d}", .{ expr.literal.value.number });
        },
      }
    },
    .unary => {},
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
  try std.testing.expect(std.mem.eql(u8, result.items, "lol"));
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

// test "ast unary" {
//   const lit = expressions.Expr{
//     .literal = .{
//       .value = .{
//         .string = "haha",
//       },
//     },
//   };
//   const expr = expressions.Expr{
//     .unary = .{
//       .operator = .{
//         .kind = tokens.Kind.minus,
//         .lexeme = "-",
//         .literal = tokens.Literal.nil,
//         .line = 1,
//       },
//       .right = &lit,
//     },
//   };
//   var ast = printAst(expr);
//   // defer std.testing.allocator.free(ast);
//   std.debug.print("\n{s}\n", .{ ast });
//   try std.testing.expect(std.mem.eql(u8, ast, "-haha"));
// }
