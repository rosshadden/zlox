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
    const b_len = 32;
    var b: [b_len]u8 = undefined;
    const where = std.fmt.bufPrint(&b, "at '{s}'", .{ token.lexeme }) catch blk: {
      std.mem.copy(u8, b[b_len - 3 ..], "..'");
      break :blk &b;
    };
    report(token.line, where, message);
  }
}
