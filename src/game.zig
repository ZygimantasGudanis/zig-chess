const std = @import("std");
const pieces = @import("pieces.zig");

const ChessPiece = pieces.ChessPiece;

const print = std.debug.print;

pub const Square = struct {
    column: u8,
    row: u8,
    piece: ?pieces.Piece,

    pub fn init(board: *Game, piece: pieces.Piece) ?Square {
        var column: u8 = 0;
        var row: u8 = 0;
        while (column < board.*.board.len) : (column += 1) {
            while (row < board.*.board[column].len) : (row += 1) {
                if (*piece == *board.*.board[column][row]) {
                    return Square{
                        .column = column,
                        .row = row,
                        .piece = piece,
                    };
                }
            }
        }
        return null;
    }

    pub fn init2(board: *Game, column: u8, row: u8) Square {
        return Square{
            .column = column,
            .row = row,
            .piece = board.*.board[column][row],
        };
    }
};

pub const Move = struct {
    row: u8,
    column: u8,
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
    print("Total moves for bishop: {}\n", .{try pieceMoves(game, Square.init2(game, 3, 1))});
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

pub fn pieceMoves(game: *Game, square: Square) !u8 {
    if (square.piece == null) {
        print("is null", .{});
        return 255;
    }
    switch (square.piece.?.piece) {
        .Bishop => return bishopMoves(game, square),
        .King => return kingMoves(game, square),
        .Knight => return 0,
        .Pawn => return pawnMoves(game, square),
        .Queen => return queenMoves(game, square),
        .Rook => return rookMoves(game, square),
    }
}

pub fn pawnMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);

    var totalMoves: u8 = 0;
    var row = square.row;
    if (square.piece.?.isWhite()) row += 1 else row -= 1;

    if (!square.piece.?.hasMoved) {
        const firstMove = if (square.piece.?.isWhite()) row + 1 else row - 1;

        if (game.board[square.column][row] == null) totalMoves += 1;
        if (game.board[square.column][row] == null and game.board[square.column][firstMove] == null)
            totalMoves += 1;
    } else if (game.board[square.column][row] == null)
        totalMoves += 1;

    if (square.column > 0 and game.board[square.column - 1][row] != null and game.board[square.column - 1][row].?.side != square.piece.?.side) {
        totalMoves += 1;
    }
    if (square.column < 7 and game.board[square.column + 1][row] != null and game.board[square.column + 1][row].?.side != square.piece.?.side) {
        totalMoves += 1;
    }

    return totalMoves;
}

pub fn rookMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;

    if (!square.piece.?.hasMoved) {
        if (square.column == 7) {
            var i = square.column - 1;
            while (i > 0) : (i -= 1) {
                const piece = game.board[i][square.row];
                if (piece == null) continue;
                if (piece.?.piece != ChessPiece.King) break;

                //rook lift
            }
        }

        if (square.column == 0) {
            var i = square.column + 1;
            while (i < game.board.len) : (i += 1) {
                const piece = game.board[i][square.row];
                if (piece == null) continue;
                if (piece.?.piece != ChessPiece.King) break;

                //rook lift if no Checks in path
            }
        }
    }

    totalMoves += lines(game, square);
    return totalMoves;
}

fn bishopMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;
    totalMoves += diagnal(game, square);
    return totalMoves;
}

fn queenMoves(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    var totalMoves: u8 = 0;
    totalMoves += diagnal(game, square);
    totalMoves += lines(game, square);
    return totalMoves;
}

fn kingMoves(game: *Game, square: Square) !u8 {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.King);

    var moves = std.ArrayList(Move).init(game.allocator);
    defer moves.deinit();
    if (square.column < 7) {
        if (game.board[square.column + 1][square.row] == null)
            _ = try moves.append(Move{ .column = square.row, .row = square.column + 1 });
        if (square.row < 7 and game.board[square.column + 1][square.row + 1] == null)
            _ = try moves.append(Move{ .column = square.row + 1, .row = square.column + 1 });
        if (square.row > 0 and game.board[square.column + 1][square.row - 1] == null)
            _ = try moves.append(Move{ .column = square.row - 1, .row = square.column + 1 });
    }

    if (square.column > 0) {
        if (game.board[square.column - 1][square.row] == null)
            _ = try moves.append(Move{ .column = square.row, .row = square.column - 1 });
        if (square.row < 7 and game.board[square.column - 1][square.row + 1] == null)
            _ = try moves.append(Move{ .column = square.row + 1, .row = square.column - 1 });
        if (square.row > 0 and game.board[square.column - 1][square.row - 1] == null)
            _ = try moves.append(Move{ .column = square.row - 1, .row = square.column - 1 });
    }

    if (square.row < 7) {
        if (game.board[square.column][square.row + 1] == null)
            _ = try moves.append(Move{ .column = square.row + 1, .row = square.column });
    }

    if (square.row > 0) {
        if (game.board[square.column][square.row - 1] == null)
            _ = try moves.append(Move{ .column = square.row - 1, .row = square.column - 1 });
    }

    if (!square.piece.?.hasMoved) {
        var i = square.column - 1;
        while (i > 0) : (i -= 1) {
            const piece = game.board[i][square.row];
            if (piece == null) continue;
            if (piece.?.piece != ChessPiece.Rook) break;

            _ = try moves.append(Move{ .column = square.row - 1, .row = square.column - 2 });
            //rook lift
        }

        i = square.column + 1;
        while (i < game.board.len) : (i += 1) {
            const piece = game.board[i][square.row];
            if (piece == null) continue;
            if (piece.?.piece != ChessPiece.Rook) break;

            _ = try moves.append(Move{ .column = square.row - 1, .row = square.column + 2 });
        }
    }

    return @as(u8, @intCast(moves.items.len));
}

fn lines(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Rook);

    var totalMoves: u8 = 0;
    if (square.column < 7) {
        for (square.column + 1..8) |i| {
            if (game.board[i][square.row] == null) {
                totalMoves += 1;
                continue;
            }
            if (game.board[i][square.row].?.side != square.piece.?.side) {
                totalMoves += 1;
            } else break;
        }
    }

    if (square.column > 0) {
        for (0..square.column - 1) |i| {
            if (game.board[i][square.row] == null) {
                totalMoves += 1;
                continue;
            }
            if (game.board[i][square.row].?.side != square.piece.?.side) {
                totalMoves += 1;
            } else break;
        }
    }

    if (square.row < 7) {
        for (square.row + 1..8) |i| {
            if (game.board[square.column][i] == null) {
                totalMoves += 1;
                continue;
            }
            if (game.board[square.column][i].?.side != square.piece.?.side) {
                totalMoves += 1;
            } else break;
        }
    }

    if (square.row > 0) {
        for (0..square.row - 1) |i| {
            if (game.board[square.column][i] == null) {
                totalMoves += 1;
                continue;
            }
            if (game.board[square.column][i].?.side != square.piece.?.side) {
                totalMoves += 1;
            } else break;
        }
    }
    return totalMoves;
}

fn diagnal(game: *Game, square: Square) u8 {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Bishop);

    var minValue = min(@as(u8, game.board.len) - square.row, @as(u8, game.board.len) - square.column);
    var totalMoves: u8 = 0;
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column + i][square.row + i];
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    totalMoves += 1;
                break;
            }
            totalMoves += 1;
        }
    }
    minValue = min(square.row, square.column) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column - i][square.row - i];
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    totalMoves += 1;
                break;
            }
            totalMoves += 1;
        }
    }

    minValue = min(@as(u8, game.board.len) - square.row, square.column) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column - i][square.row + i];
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    totalMoves += 1;
                break;
            }
            totalMoves += 1;
        }
    }

    minValue = min(square.row, @as(u8, game.board.len) - square.column) + 1;
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column + i][square.row - i];
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    totalMoves += 1;
                break;
            }
            totalMoves += 1;
        }
    }
    return totalMoves;
}

fn min(a: u8, b: u8) u8 {
    if (a < b) return a;
    return b;
}

// column 1 2 3 4

// row
//   1
//   2
//   3
//   4
