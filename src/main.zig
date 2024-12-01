const std = @import("std");
const pieces = @import("pieces.zig");
const gameLib = @import("game.zig");

//zig run src\main.zig

//zig run src/main.zig -O Debug

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var game = try gameLib.Game.init(arena.allocator());

    try gameLib.gameLoop(&game);
}
