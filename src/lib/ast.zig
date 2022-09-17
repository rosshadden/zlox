const std = @import("std");

const expressions = @import("./expressions.zig");
const tokens = @import("./tokens.zig");

fn paren(name: []const u8, exprs: []expressions.Expr) ![]const u8 {
  var result = std.ArrayList(u8).init();

  try result.append('(');
  try result.appendSlice(name);
  for (exprs) |expr| {
    try result.append(' ');
    try result.appendSlice(printAst(expr));
  }
  try result.append(')');

  return result.toOwnedSlice();
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

test "ast literal nil" {
  const expr = expressions.Expr{
    .literal = .{
      .value = tokens.Literal.nil,
    },
  };
  const w = std.io.getStdErr().writer();
  try printAst(w, expr);
  try w.print("\n", .{});
}

test "ast literal string" {
  const expr = expressions.Expr{
    .literal = .{
      .value = .{
        .string = "lol",
      },
    },
  };
  const w = std.io.getStdErr().writer();
  try printAst(w, expr);
  try w.print("\n", .{});

  // defer std.testing.allocator.free(ast);
  // std.debug.print("\n{s}\n", .{ ast });
  // try std.testing.expect(std.mem.eql(u8, ast, "lol"));
}

test "ast literal number" {
  const expr = expressions.Expr{
    .literal = .{
      .value = .{
        .number = 4,
      },
    },
  };
  const w = std.io.getStdErr().writer();
  try printAst(w, expr);
  try w.print("\n", .{});
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
