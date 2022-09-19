const std = @import("std");

const Token = @import("./tokens.zig").Token;

pub const Parser = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  tokens: std.ArrayList(Token),
  current: usize = 0,

  pub fn init(alc: std.mem.Allocator, tokens: std.ArrayList(Token)) Self {
    return Self{
      .allocator = alc,
      .tokens = tokens,
    };
  }

  pub fn deinit(_: *Self) void {
  }
};

test "init" {
  var tokens = std.ArrayList(Token).init(std.testing.allocator);
  defer tokens.deinit();
  var parser = Parser.init(std.testing.allocator, tokens);
  defer parser.deinit();
  std.debug.print("{}\n", .{ parser.current });
}

test "" {
}
