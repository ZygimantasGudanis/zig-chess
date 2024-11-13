const std = @import("std");
const pieces = @import("pieces.zig");

const print = std.debug.print;

pub const Game = struct {
    pieces: []pieces.Piece = undefined,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) !Game {
        var gamePieces = try alloc.alloc(pieces.Piece, 32);
        const game = Game{ .pieces = gamePieces, .allocator = alloc };

        for (0..8) |i| {
            gamePieces[i] = pieces.Piece{ .pawn = pieces.ChessPawn{ .column = @intCast(i), .row = 1, .side = pieces.Side.White } };
        }

        const majorPieces = .{ pieces.ChessRook, pieces.ChessKnight, pieces.ChessBishop, pieces.ChessKing, pieces.ChessQueen, pieces.ChessBishop, pieces.ChessKnight, pieces.ChessRook };
        print("{}\n", .{pieces.ChessRook});
        inline for (majorPieces, 8..) |major, index| {
            const rez = doWork(major, index, 0, pieces.Side.White);
            gamePieces[index] = rez;
        }

        return game;
    }
    pub fn deinit(self: Game) void {
        self.allocator.free(pieces);
    }
};

fn doWork(piece: anytype, column: u8, row: u8, side: pieces.Side) pieces.Piece {
    switch (piece) {
        pieces.ChessRook => return pieces.Piece{ .rook = pieces.ChessRook{ .column = column, .row = row, .side = side } },
        pieces.ChessBishop => return pieces.Piece{ .bishop = pieces.ChessBishop{ .column = column, .row = row, .side = side } },
        pieces.ChessKnight => return pieces.Piece{ .knight = pieces.ChessKnight{ .column = column, .row = row, .side = side } },
        pieces.ChessKing => return pieces.Piece{ .king = pieces.ChessKing{ .column = column, .row = row, .side = side } },
        pieces.ChessQueen => return pieces.Piece{ .queen = pieces.ChessQueen{ .column = column, .row = row, .side = side } },
        else => return pieces.Piece{ .pawn = pieces.ChessPawn{ .column = 1, .row = 1, .side = pieces.Side.White } },
    }
}

//   a b c d e f g h
//   1 2 3 4 5 6 7 8
// 1 R K B K Q B K R
// 2
// 3
// 4
// 5
// 6
// 7
// 8
