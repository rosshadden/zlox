const std = @import("std");

const Parser = @import("./lib/parser.zig").Parser;
const Scanner = @import("./lib/scanner.zig").Scanner;
const ast = @import("./lib/ast.zig");
const expressions = @import("./lib/expressions.zig");
const helpers = @import("./lib/helpers.zig");

const stderr = std.io.getStdErr().writer();
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
  const args = std.os.argv[1 .. std.os.argv.len];

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const alc = gpa.allocator();

  switch (args.len) {
    0 => {
      try repl(alc);
    },
    1 => {
      const path = std.mem.sliceTo(args[0], '0');
      try runFile(alc, path);
    },
    else => {
      std.log.err("Usage: lox [script]", .{});
      std.process.exit(0);
    },
  }
}

fn runFile(alc: std.mem.Allocator, path: []const u8) !void {
  const source = try std.fs.cwd().readFileAlloc(alc, path, 1_000_000);
  defer alc.free(source);
  try run(alc, source);

  if (helpers.hadError) std.process.exit(65);
}

fn repl(alc: std.mem.Allocator) !void {
  while (true) {
    try stdout.print("> ", .{});
    if (stdin.readUntilDelimiterOrEofAlloc(alc, '\n', 255) catch null) |source| {
      defer alc.free(source);
      try run(alc, source);
      helpers.hadError = false;
    } else {
      break;
    }
    try stdout.print("\n", .{});
  }
}

fn run(alc: std.mem.Allocator, source: []const u8) !void {
  var scanner = Scanner.init(alc, source);
  defer scanner.deinit();

  const tokens = try scanner.scanTokens();
  // defer tokens.deinit();

  var parser = Parser.init(alc, tokens);
  defer parser.deinit();

  // TOOD: wtf
  _ = try parser.parse();
  // const expr = try parser.parse();

  if (helpers.hadError) return;

  // try ast.printAst(std.io.getStdErr().writer(), expr);
  // ast.printAst(std.io.getStdErr().writer(), &expr);

  // for (tokens) |token| {
  //   std.debug.print("{s}", .{ @tagName(token.kind) });
  //   switch (token.literal) {
  //     .identifier => std.debug.print(":\t{s}", .{ token.literal.identifier }),
  //     .string => std.debug.print(":\t\"{s}\"", .{ token.literal.string }),
  //     .number => std.debug.print(":\t{d}", .{ token.literal.number }),
  //     else => {}
  //   }
  //   std.debug.print("\n", .{});
  // }
}
