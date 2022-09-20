const std = @import("std");

const tokens = @import("./tokens.zig");

pub var hadError = false;

pub fn report(line: usize, where: []const u8, message: []const u8) void {
  std.debug.print("[line {d}] Error{s}: {s}", .{ line, where, message });
  hadError = true;
}

// @error
pub fn errorLine(line: usize, message: []const u8) void {
  report(line, "", message);
}

// @error
pub fn errorToken(token: tokens.Token, message: []const u8) void {
  if (token.kind == tokens.Kind.eof) {
    report(token.line, " at end", message);
  } else {
    report(token.line, " at '" + token.lexeme + "'", message);
  }
}
