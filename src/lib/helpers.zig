const std = @import("std");

pub var hadError = false;

pub fn err(line: usize, message: []const u8) void {
  report(line, "", message);
}

pub fn report(line: usize, where: []const u8, message: []const u8) void {
  std.debug.print("[line {d}] Error{s}: {s}", .{ line, where, message });
  hadError = true;
}
