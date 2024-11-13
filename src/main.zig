const std = @import("std");
const pieces = @import("pieces.zig");
const gameLib = @import("game.zig");

//zig run src\main.zig

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
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

    const game = try gameLib.Game.init(arena.allocator());
    //defer game.deinit();
    const piece = game.pieces[0];
    try printPiece(piece);
    //print("{}", .{piece});
}

pub fn printBoard() !void {
    const line = [_]u8{'-'} ** 33;
    try print("{s}\n", .{line});
    for (0..8) |_| {
        for (0..1) |_| {
            for (0..8) |_| {
                print("|   ", .{});
            }
            print("|\n", .{});
        }
        print("{s}\n", .{line});
    }
}

pub fn printPiece(piece: pieces.Piece) !void {
    switch (piece) {
        .pawn => |p| print("Side : {}", .{p.side}),
        .bishop => |p| print("Side : {}", .{p.side}),
        .king => |p| print("Side : {}", .{p.side}),
        .queen => |p| print("Side : {}", .{p.side}),
        .rook => |p| print("Side : {}", .{p.side}),
        .knight => |p| print("Side : {}", .{p.side}),
    }
}
