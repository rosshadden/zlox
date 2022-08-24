const std = @import("std");

pub var hadError = false;

pub fn err(line: u8, message: []const u8) void {
  report(line, "", message);
}

pub fn report(line: u8, where: []const u8, message: []const u8) void {
  std.debug.print("[line {d}] Error{}: {}", .{ line, where, message });
  hadError = true;
}
