const std = @import("std");

const helpers = @import("./helpers.zig");
const scanner = @import("./scanner.zig");

const expect = std.testing.expect;
const stderr = std.io.getStdErr().writer();
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
  const args = std.os.argv[1..std.os.argv.len];

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();

  switch (args.len) {
    0 => {
      try repl(allocator);
    },
    1 => {
      const path = std.mem.sliceTo(args[0], '0');
      try runFile(allocator, path);
    },
    else => {
      std.log.err("Usage: lox [script]", .{});
      std.process.exit(0);
    },
  }
}

fn runFile(allocator: std.mem.Allocator, path: []const u8) !void {
  const source = try std.fs.cwd().readFileAlloc(allocator, path, 1_000_000);
  defer allocator.free(source);
  run(source);

  if (helpers.hadError) std.process.exit(65);
}

fn repl(allocator: std.mem.Allocator) !void {
  while (true) {
    try stdout.print("> ", .{});
    if (stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 255) catch null) |source| {
      defer allocator.free(source);
      run(source);
      helpers.hadError = false;
    } else {
      break;
    }
    try stdout.print("\n", .{});
  }
}

fn run(source: []const u8) void {
  std.debug.print("{s}", .{ source });
}
