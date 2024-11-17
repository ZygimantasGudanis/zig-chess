const std = @import("std");
const pieces = @import("pieces.zig");

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
            board[i][1] = pieces.Piece{ .pawn = pieces.ChessPawn{ .side = pieces.Side.White } };
        }

        for (0..8) |i| {
            board[i][6] = pieces.Piece{ .pawn = pieces.ChessPawn{ .side = pieces.Side.Black } };
        }

        const majorPieces = .{ pieces.ChessRook, pieces.ChessKnight, pieces.ChessBishop, pieces.ChessKing, pieces.ChessQueen, pieces.ChessBishop, pieces.ChessKnight, pieces.ChessRook };
        inline for (majorPieces, 0..) |major, index| {
            const rez = createPiece(major, pieces.Side.White);
            board[index][0] = rez;
        }

        inline for (majorPieces, 0..) |major, index| {
            const rez = createPiece(major, pieces.Side.Black);
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

fn createPiece(piece: anytype, side: pieces.Side) pieces.Piece {
    switch (piece) {
        pieces.ChessRook => return pieces.Piece{ .rook = pieces.ChessRook{ .side = side } },
        pieces.ChessBishop => return pieces.Piece{ .bishop = pieces.ChessBishop{ .side = side } },
        pieces.ChessKnight => return pieces.Piece{ .knight = pieces.ChessKnight{ .side = side } },
        pieces.ChessKing => return pieces.Piece{ .king = pieces.ChessKing{ .side = side } },
        pieces.ChessQueen => return pieces.Piece{ .queen = pieces.ChessQueen{ .side = side } },
        else => return null,
    }
}

pub fn printBoard2(game: *Game) !void {
    const line = [_]u8{'-'} ** 33;
    print("Total moves for pawn: {}\n", .{pawnMoves(game, Square.init2(game, 1, 1))});
    print("{s}\n", .{line});
    for (0..8) |i| {
        for (0..1) |_| {
            for (0..8) |j| {
                const piece = game.board[j][i];
                if (piece == null) {
                    print("|   ", .{});
                } else {
                    print("| {s} ", .{piece.?.name()});
                }
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

pub fn pawnMoves(game: *Game, square: Square) u8 {
    if (square.piece == null) return 0;
    var totalMoves: u8 = 0;
    var column = square.column;
    if (square.piece.?.isWhite()) column += 1 else column -= 1;

    if (!square.piece.?.pawn.hasMoved) {
        const firstMove = if (square.piece.?.isWhite()) column + 1 else column - 1;

        if (game.board[square.row][column] == null) totalMoves += 1;
        if (game.board[square.row][column] == null and game.board[square.row][firstMove] == null)
            totalMoves += 1;
    } else if (game.board[square.row][column] == null)
        totalMoves += 1;

    if (square.row > 0 and game.board[square.row - 1][column] != null and game.board[square.row - 1][column].?.sideOf() != square.piece.?.sideOf()) {
        totalMoves += 1;
    }
    if (square.row < 7 and game.board[square.row + 1][column] != null and game.board[square.row + 1][column].?.sideOf() != square.piece.?.sideOf()) {
        totalMoves += 1;
    }

    return totalMoves;
    // square.piece.pawn.hasMoved
}
