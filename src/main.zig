const std = @import("std");
const pieces = @import("pieces.zig");
const gameLib = @import("game.zig");

//zig run src\main.zig

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var game = try gameLib.Game.init(arena.allocator());
    //defer game.deinit();
    try gameLib.printBoard2(&game);

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();
    // try stdout.print("{}.\n", .{piece.canMove()});
    // try bw.flush(); // don't forget to flush!

    //const piece = game.Piece{ .pawn = game.ChessPawn{} };
    // const board = game.Board{};

    //print("{}.\n", .{piece.canMove()});
    //try printBoard(stdout);
    //print("{}", .{piece});
}
