const std = @import("std");
const pieces = @import("pieces.zig");

const ChessPiece = pieces.ChessPiece;

const print = std.debug.print;

pub const Square = struct {
    row: u8,
    column: u8,
    piece: ?pieces.Piece,

    pub fn init(board: *Game, piece: pieces.Piece) ?Square {
        var row: u8 = 0;
        var column: u8 = 0;
        while (row < board.*.board.len) : (row += 1) {
            while (column < board.*.board[row].len) : (column += 1) {
                if (*piece == *board.*.board[row][column]) {
                    return Square{
                        .row = row,
                        .column = column,
                        .piece = piece,
                    };
                }
            }
        }
        return null;
    }

    pub fn init2(board: *Game, row: u8, column: u8) Square {
        return Square{
            .row = row,
            .column = column,
            .piece = board.*.board[row][column],
        };
    }
};

pub const Game = struct {
    board: [8][8]?pieces.Piece,
    allocator: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) !Game {
        var board = [8][8]?pieces.Piece{
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
            .{null} ** 8,
        };

        for (0..8) |i| {
            board[i][1] = pieces.Piece{
                .side = pieces.Side.White,
                .piece = ChessPiece.Pawn,
            };
        }

        for (0..8) |i| {
            board[i][6] = pieces.Piece{
                .side = pieces.Side.Black,
                .piece = ChessPiece.Pawn,
            };
        }

        const majorPieces = [_]ChessPiece{ ChessPiece.Rook, ChessPiece.Knight, ChessPiece.Bishop, ChessPiece.King, ChessPiece.Queen, ChessPiece.Bishop, ChessPiece.Knight, ChessPiece.Rook };
        inline for (majorPieces, 0..) |major, index| {
            const rez = pieces.Piece{
                .side = pieces.Side.White,
                .piece = major,
            };
            board[index][0] = rez;
        }

        inline for (majorPieces, 0..) |major, index| {
            const rez = pieces.Piece{
                .side = pieces.Side.Black,
                .piece = major,
            };
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

pub fn printBoard2(game: *Game) !void {
    const line = [_]u8{'-'} ** 33;
    print("Total moves for bishop: {}\n", .{pieceMoves(game, Square.init2(game, 2, 0))});
    print("{}\n", .{game.board[3][0].?.piece});
    print("{s}\n", .{line});
    for (0..8) |i| {
        for (0..8) |j| {
            const piece = game.board[j][i];
            if (piece == null) {
                print("|   ", .{});
            } else {
                print("| {s} ", .{piece.?.symbols()});
            }
        }
        print("|\n", .{});

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

pub fn pieceMoves(game: *Game, square: Square) u8 {
    switch (square.piece.?.piece) {
        .Bishop => return bishopMoves(game, square),
        .King => return 0,
        .Knight => return 0,
        .Pawn => return pawnMoves(game, square),
        .Queen => return queenMoves(game, square),
        .Rook => return rookMoves(game, square),
    }
}

pub fn pawnMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);

    var totalMoves: u8 = 0;
    var column = square.column;
    if (square.piece.?.isWhite()) column += 1 else column -= 1;

    if (!square.piece.?.hasMoved) {
        const firstMove = if (square.piece.?.isWhite()) column + 1 else column - 1;

        if (game.board[square.row][column] == null) totalMoves += 1;
        if (game.board[square.row][column] == null and game.board[square.row][firstMove] == null)
            totalMoves += 1;
    } else if (game.board[square.row][column] == null)
        totalMoves += 1;

    if (square.row > 0 and game.board[square.row - 1][column] != null and game.board[square.row - 1][column].?.side != square.piece.?.side) {
        totalMoves += 1;
    }
    if (square.row < 7 and game.board[square.row + 1][column] != null and game.board[square.row + 1][column].?.side != square.piece.?.side) {
        totalMoves += 1;
    }

    return totalMoves;
}

pub fn rookMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;

    if (!square.piece.?.hasMoved) {
        if (square.row == 7) {
            var i = square.row - 1;
            while (i > 0) : (i -= 1) {
                const piece = game.board[i][square.column];
                if (piece == null) continue;
                if (piece.?.piece != ChessPiece.King) break;

                //rook lift
            }
        }

        if (square.row == 0) {
            var i = square.row + 1;
            while (i < game.board.len) : (i += 1) {
                const piece = game.board[i][square.column];
                if (piece == null) continue;
                if (piece.?.piece != ChessPiece.King) break;

                //rook lift if no Checks in path
            }
        }
    }

    totalMoves += lines(game, square);
    return totalMoves;
}

pub fn bishopMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;
    totalMoves += diagnal(game, square);
    return totalMoves;
}

pub fn queenMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;
    totalMoves += diagnal(game, square);
    totalMoves += lines(game, square);
    return totalMoves;
}

fn lines(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Rook);

    var totalMoves: u8 = 0;
    if (square.row < 7) {
        for (square.row + 1..8) |i| {
            if (game.board[i][square.column] == null) {
                totalMoves += 1;
            }
        }
    }

    if (square.row > 0) {
        for (0..square.row - 1) |i| {
            if (game.board[i][square.column] == null) {
                totalMoves += 1;
            }
        }
    }

    if (square.column < 7) {
        for (square.column + 1..8) |i| {
            if (game.board[square.row][i] == null) {
                totalMoves += 1;
            }
        }
    }

    if (square.column > 0) {
        for (0..square.column - 1) |i| {
            if (game.board[square.row][i] == null) {
                totalMoves += 1;
            }
        }
    }
    return totalMoves;
}

fn diagnal(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Bishop);

    var minValue = min(@as(u8, game.board.len) - square.column, @as(u8, game.board.len) - square.row);
    var totalMoves: u8 = 0;
    if (minValue > 0) {
        for (1..minValue) |i| {
            if (game.board[square.row + i][square.column + i] != null) break;
            totalMoves += 1;
        }
    }
    minValue = min(square.column, square.row) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            if (game.board[square.row - i][square.column - i] != null) break;
            totalMoves += 1;
        }
    }

    minValue = min(@as(u8, game.board.len) - square.column, square.row) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            if (game.board[square.row - i][square.column + i] != null) break;
            totalMoves += 1;
        }
    }

    minValue = min(square.column, @as(u8, game.board.len) - square.row) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            if (game.board[square.row + i][square.column - i] != null) break;
            totalMoves += 1;
        }
    }
    return totalMoves;
}

fn min(a: u8, b: u8) u8 {
    if (a < b) return a;
    return b;
}

// row 1 2 3 4

// column
//   1
//   2
//   3
//   4
