const std = @import("std");

const tokens = @import("./tokens.zig");

pub const Expr = union(enum) {
  binary: BinaryExpr,
  grouping: GroupingExpr,
  literal: LiteralExpr,
  unary: UnaryExpr,
};

pub const BinaryExpr = struct {
  left: *const Expr,
  operator: tokens.Token,
  right: *const Expr,
};

pub const LiteralExpr = struct {
  value: tokens.Literal,
};

pub const UnaryExpr = struct {
  operator: tokens.Token,
  right: *const Expr,
};

pub const GroupingExpr = struct {
  expression: *const Expr,
};
