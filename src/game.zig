const std = @import("std");
const pieces = @import("pieces.zig");

const print = std.debug.print;

pub const Game = struct {
    board: [8][8]?pieces.Piece,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) !Game {
        var board = [8][8]?pieces.Piece{
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
            .{pieces.Piece{ .empty = pieces.ChessEmpty{ .side = pieces.Side.empty } }} ** 8,
        };
        board = undefined;
        for (0..8) |i| {
            board[i][1] = pieces.Piece{ .pawn = pieces.ChessPawn{ .side = pieces.Side.White } };
        }

        for (0..8) |i| {
            board[i][6] = pieces.Piece{ .pawn = pieces.ChessPawn{ .side = pieces.Side.Black } };
        }

        const majorPieces = .{ pieces.ChessRook, pieces.ChessKnight, pieces.ChessBishop, pieces.ChessKing, pieces.ChessQueen, pieces.ChessBishop, pieces.ChessKnight, pieces.ChessRook };
        inline for (majorPieces, 0..) |major, index| {
            const rez = doWork(major, pieces.Side.White);
            board[index][0] = rez;
        }

        inline for (majorPieces, 0..) |major, index| {
            const rez = doWork(major, pieces.Side.Black);
            board[index][7] = rez;
        }

        return Game{
            .allocator = alloc,
            .board = board,
        };
    }
    pub fn deinit(self: Game) void {
        self.allocator.free(pieces);
    }
};

fn doWork(piece: anytype, side: pieces.Side) pieces.Piece {
    switch (piece) {
        pieces.ChessRook => return pieces.Piece{ .rook = pieces.ChessRook{ .side = side } },
        pieces.ChessBishop => return pieces.Piece{ .bishop = pieces.ChessBishop{ .side = side } },
        pieces.ChessKnight => return pieces.Piece{ .knight = pieces.ChessKnight{ .side = side } },
        pieces.ChessKing => return pieces.Piece{ .king = pieces.ChessKing{ .side = side } },
        pieces.ChessQueen => return pieces.Piece{ .queen = pieces.ChessQueen{ .side = side } },
        else => return null,
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
