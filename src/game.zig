const std = @import("std");
const pieces = @import("pieces.zig");

const ChessPiece = pieces.ChessPiece;

const print = std.debug.print;

const ChessError = error{PieceNull};

pub const Square = struct {
    column: u8,
    row: u8,
    piece: ?pieces.Piece = null,

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

pub fn gameLoop(game: *Game) !void {
    var buf = try game.allocator.alloc(u8, 10);
    defer game.allocator.free(buf);
    const reader = std.io.getStdIn().reader();

    var side = pieces.Side.White;
    //TODO: Use tokenizer
    while (true) {
        try printBoard(game);
        print("Select piece...\n", .{});
        var user_move = try input(reader, &buf) orelse Square{ .column = 255, .row = 255 };

        if (user_move.column > 7 and user_move.row > 7) {
            print("Bad input. Column: {}, Row: {}.\n", .{ user_move.column, user_move.row });
            continue;
        }

        const piece = game.board[user_move.column][user_move.row];
        if (piece == null) {
            print("Select a different square. Piece is null.\n", .{});
            continue;
        }
        if (piece.?.side != side) {
            print("Select a different square\n", .{});
            continue;
        }

        print("Piece is {}\n", .{piece.?.piece});
        const square = Square.init2(game, user_move.column, user_move.row);
        const moves = try pieceMoves(game, square);
        if (moves.len == 0) continue;
        printMoves(moves);

        user_move = try input(reader, &buf) orelse Square{ .column = 255, .row = 255 };
        var move = validateMove(moves, user_move);
        while (move == null) {
            print("Invalid move Column: {}, Row: {}\n", .{ user_move.column, user_move.row });
            user_move = try input(reader, &buf) orelse Square{ .column = 255, .row = 255 };
            move = validateMove(moves, user_move);
        }

        makeMove(game, square, move.?) catch {
            print("Invalid move Column: {}, Row: {}\n", .{ move.?.column, move.?.row });
            continue;
        };

        if (side == pieces.Side.White) side = pieces.Side.Black else side = pieces.Side.White;
    }
}

pub fn printBoard(game: *Game) !void {
    const line = [_]u8{'-'} ** 33;
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

fn printMoves(moves: []Square) void {
    for (moves) |move| {
        if (move.piece == null) {
            print("Total moves: column {}, row {}\n", .{ move.column, move.row });
        } else {
            print("Total moves: column {}, row {}, Take Piece {}\n", .{ move.column, move.row, move.piece.?.piece });
        }
    }
}

pub fn printPiece(piece: ?pieces.Piece) !void {
    switch (piece) {
        .pawn => |p| print("Side : {}", .{p.side}),
        .bishop => |p| print("Side : {}", .{p.side}),
        .king => |p| print("Side : {}", .{p.side}),
        .queen => |p| print("Side : {}", .{p.side}),
        .rook => |p| print("Side : {}", .{p.side}),
        .knight => |p| print("Side : {}", .{p.side}),
        else => unreachable,
    }
}

pub fn pieceMoves(game: *Game, square: Square) ![]Square {
    if (square.piece == null) {
        print("is null", .{});
        return ChessError.PieceNull;
    }
    switch (square.piece.?.piece) {
        .Bishop => return try bishopMoves(game, square),
        .King => return try kingMoves(game, square),
        .Knight => return try knightMoves(game, square),
        .Pawn => return try pawnMoves(game, square),
        .Queen => return try queenMoves(game, square),
        .Rook => return try rookMoves(game, square),
    }
}

fn makeMove(game: *Game, square: Square, move: Square) !void {
    //print("{}{}{any}\n", square);
    if (square.piece == null) return ChessError.PieceNull;

    // Rook lift
    if (square.piece.?.piece == ChessPiece.King and move.piece != null) {
        const rookLift = move.piece.?.side == square.piece.?.side and move.piece.?.piece == ChessPiece.Rook;
        if (rookLift) {
            if (square.column > move.column) {
                game.board[square.column - 2][square.row] = game.board[square.column][square.row];
                game.board[square.column][square.row] = null;

                game.board[square.column - 1][square.row] = game.board[move.column][move.row];
                game.board[move.column][move.row] = null;
            } else {
                game.board[square.column + 2][square.row] = game.board[square.column][square.row];
                game.board[square.column][square.row] = null;

                game.board[square.column + 1][square.row] = game.board[move.column][move.row];
                game.board[move.column][move.row] = null;
            }
        }
        return;
    }
    game.board[square.column][square.row].?.hasMoved = true;
    game.board[move.column][move.row] = game.board[square.column][square.row];
    game.board[square.column][square.row] = null;
}

fn pawnMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);

    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();
    var row = square.row;
    if (square.piece.?.isWhite()) row += 1 else row -= 1;

    if (!square.piece.?.hasMoved) {
        const firstMove = if (square.piece.?.isWhite()) row + 1 else row - 1;

        if (game.board[square.column][row] == null)
            try moves.append(Square{ .column = square.column, .row = row });
        if (game.board[square.column][row] == null and game.board[square.column][firstMove] == null)
            try moves.append(Square{ .column = square.column, .row = firstMove });
    } else if (game.board[square.column][row] == null)
        try moves.append(Square{ .column = square.column, .row = row });

    if (square.column > 0 and game.board[square.column - 1][row] != null and game.board[square.column - 1][row].?.side != square.piece.?.side)
        try moves.append(Square{ .column = square.column - 1, .row = row, .piece = game.board[square.column - 1][row] });

    if (square.column < 7 and game.board[square.column + 1][row] != null and game.board[square.column + 1][row].?.side != square.piece.?.side)
        try moves.append(Square{ .column = square.column + 1, .row = row, .piece = game.board[square.column + 1][row] });

    return moves.toOwnedSlice();
}

fn rookMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();
    try moves.appendSlice(try lines(game, square));
    return moves.toOwnedSlice();
}

fn bishopMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    return try diagnal(game, square);
}

fn queenMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();

    try moves.appendSlice(try diagnal(game, square));
    try moves.appendSlice(try lines(game, square));

    return moves.toOwnedSlice();
}

fn kingMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.King);

    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();
    if (square.column < 7) {
        if ((game.board[square.column + 1][square.row] == null or game.board[square.column + 1][square.row].?.side != square.piece.?.side))
            try moves.append(Square{ .column = square.column + 1, .row = square.row, .piece = game.board[square.column + 1][square.row] });
        if (square.row < 7 and (game.board[square.column + 1][square.row + 1] == null or game.board[square.column + 1][square.row + 1].?.side != square.piece.?.side))
            try moves.append(Square{ .column = square.column + 1, .row = square.row + 1, .piece = game.board[square.column + 1][square.row + 1] });
        if (square.row > 0 and (game.board[square.column + 1][square.row - 1] == null or game.board[square.column + 1][square.row - 1].?.side != square.piece.?.side))
            try moves.append(Square{ .column = square.column - 1, .row = square.row + 1, .piece = game.board[square.column + 1][square.row - 1] });
    }

    if (square.column > 0) {
        if (game.board[square.column - 1][square.row] == null or game.board[square.column - 1][square.row].?.side != square.piece.?.side)
            try moves.append(Square{ .column = square.column - 1, .row = square.row, .piece = game.board[square.column - 1][square.row] });
        if (square.row < 7 and (game.board[square.column - 1][square.row + 1] == null or game.board[square.column - 1][square.row + 1].?.side != square.piece.?.side))
            try moves.append(Square{ .column = square.column + 1, .row = square.row - 1, .piece = game.board[square.column - 1][square.row] });
        if (square.row > 0 and (game.board[square.column - 1][square.row - 1] == null or game.board[square.column - 1][square.row - 1].?.side != square.piece.?.side))
            try moves.append(Square{ .column = square.column - 1, .row = square.row - 1, .piece = game.board[square.column - 1][square.row - 1] });
    }

    if (square.row < 7) {
        if (game.board[square.column][square.row + 1] == null or game.board[square.column][square.row + 1].?.side != square.piece.?.side)
            try moves.append(Square{ .column = square.column, .row = square.row + 1, .piece = game.board[square.column][square.row + 1] });
    }

    if (square.row > 0) {
        if (game.board[square.column][square.row - 1] == null or game.board[square.column][square.row - 1].?.side != square.piece.?.side)
            try moves.append(Square{ .column = square.column, .row = square.row - 1, .piece = game.board[square.column][square.row - 1] });
    }

    if (!square.piece.?.hasMoved) {
        var i = square.column - 1;
        while (true) : (i -= 1) {
            const piece = game.board[i][square.row];
            if (piece == null and i > 0) continue;
            if (!piece.?.hasMoved and piece.?.piece == ChessPiece.Rook and piece.?.side == square.piece.?.side) {
                try moves.append(Square{ .column = i, .row = square.row, .piece = piece });
                break;
            }
            break;
            //rook lift
        }

        i = square.column + 1;
        while (true) : (i += 1) {
            const piece = game.board[i][square.row];
            if (piece == null and i < game.board.len) continue;
            if (!piece.?.hasMoved and piece.?.piece == ChessPiece.Rook and piece.?.side == square.piece.?.side) {
                try moves.append(Square{ .column = i, .row = square.row, .piece = piece });
                break;
            }
            break;
        }
    }
    return moves.toOwnedSlice();
}

fn knightMoves(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Knight);

    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();

    if (square.column < 6) {
        if (square.row < 7) {
            const piece = game.board[square.column + 2][square.row + 1];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column + 2, .row = square.row + 1 });
        }
        if (square.row >= 1) {
            const piece = game.board[square.column + 2][square.row - 1];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column + 2, .row = square.row - 1 });
        }
    }
    if (square.column > 1) {
        if (square.row < 7) {
            const piece = game.board[square.column - 2][square.row + 1];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column - 2, .row = square.row + 1 });
        }
        if (square.row >= 1) {
            const piece = game.board[square.column - 2][square.row - 1];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column - 2, .row = square.row - 1 });
        }
    }
    if (square.row < 6) {
        if (square.column < 7) {
            const piece = game.board[square.column + 1][square.row + 2];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column + 1, .row = square.row + 2 });
        }
        if (square.column >= 1) {
            const piece = game.board[square.column - 1][square.row + 2];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column - 1, .row = square.row + 2 });
        }
    }
    if (square.row > 1) {
        if (square.column < 7) {
            const piece = game.board[square.column + 1][square.row - 2];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column + 1, .row = square.row - 2 });
        }
        if (square.column >= 1) {
            const piece = game.board[square.column - 1][square.row - 2];
            if (piece == null or piece.?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column - 1, .row = square.row - 2 });
        }
    }

    return moves.toOwnedSlice();
}

fn lines(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Rook);

    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();

    if (square.column < 7) {
        var offset = square.column + 1;
        while (offset <= 7) : (offset += 1) {
            if (game.board[offset][square.row] == null) {
                try moves.append(Square{ .column = offset, .row = square.row });
                continue;
            }
            if (game.board[offset][square.row].?.side != square.piece.?.side)
                try moves.append(Square{ .column = offset, .row = square.row, .piece = game.board[offset][square.row] });
            break;
        }
    }

    if (square.column > 0) {
        var offset = square.column - 1;
        while (offset >= 0) : (offset -= 1) {
            if (game.board[offset][square.row] == null) {
                try moves.append(Square{ .column = offset, .row = square.row });
                if (offset == 0) break;
                continue;
            }
            if (game.board[offset][square.row].?.side != square.piece.?.side)
                try moves.append(Square{ .column = offset, .row = square.row, .piece = game.board[offset][square.row] });
            break;
        }
    }

    if (square.row < 7) {
        var offset = square.row + 1;
        while (offset <= 7) : (offset += 1) {
            if (game.board[square.column][offset] == null) {
                try moves.append(Square{ .column = square.column, .row = offset });
                if (offset == 0) break;
                continue;
            }
            if (game.board[square.column][offset].?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column, .row = offset, .piece = game.board[square.column][offset] });
            break;
        }
    }

    if (square.row > 0) {
        var offset = square.row - 1;
        while (offset >= 0) : (offset -= 1) {
            if (game.board[square.column][offset] == null) {
                try moves.append(Square{ .column = square.column, .row = offset });
                if (offset == 0) break;
                continue;
            }
            if (game.board[square.column][offset].?.side != square.piece.?.side)
                try moves.append(Square{ .column = square.column, .row = offset, .piece = game.board[square.column][offset] });
            break;
        }
    }
    return moves.toOwnedSlice();
}

fn diagnal(game: *Game, square: Square) ![]Square {
    std.debug.assert(square.piece != null);
    std.debug.assert(square.piece.?.piece == ChessPiece.Queen or square.piece.?.piece == ChessPiece.Bishop);
    const boardLen = @as(u8, game.board.len);
    var moves = std.ArrayList(Square).init(game.allocator);
    defer moves.deinit();

    var minValue = min(boardLen - square.row, boardLen - square.column);
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column + i][square.row + i];
            const offset = @as(u8, @intCast(i));
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    try moves.append(Square{ .column = square.column + offset, .row = square.row + offset, .piece = piece });
                break;
            }
            try moves.append(Square{ .column = square.column + offset, .row = square.row + offset });
        }
    }
    minValue = min(square.row, square.column);
    if (minValue > 0) {
        for (1..minValue) |i| {
            const piece = game.board[square.column - i][square.row - i];
            const offset = @as(u8, @intCast(i));
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    try moves.append(Square{ .column = square.column - offset, .row = square.row - offset, .piece = piece });
                break;
            }
            try moves.append(Square{ .column = square.column - offset, .row = square.row - offset });
        }
    }

    minValue = min(boardLen - (square.row + 1), square.column) + 1;
    if (minValue > 0 and (boardLen - 1) != square.row) {
        for (1..minValue) |i| {
            const piece = game.board[square.column - i][square.row + i];
            const offset = @as(u8, @intCast(i));
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    try moves.append(Square{ .column = square.column - offset, .row = square.row + offset, .piece = piece });
                break;
            }
            try moves.append(Square{ .column = square.column - offset, .row = square.row + offset });
        }
    }

    minValue = min(square.row, boardLen - (square.column + 1)) + 1;
    if (minValue > 0 and (boardLen - 1) != square.column) {
        for (1..minValue) |i| {
            const piece = game.board[square.column + i][square.row - i];
            const offset = @as(u8, @intCast(i));
            if (piece != null) {
                if (piece.?.side != square.piece.?.side)
                    try moves.append(Square{ .column = square.column + offset, .row = square.row - offset, .piece = piece });
                break;
            }
            try moves.append(Square{ .column = square.column + offset, .row = square.row - offset });
        }
    }
    return moves.toOwnedSlice();
}

fn min(a: u8, b: u8) u8 {
    if (a < b) return a;
    return b;
}

fn input(reader: anytype, buf: *[]u8) !?Square {
    var user_input: ?[]u8 = reader.readUntilDelimiterOrEof(buf.*, '\n') catch {
        print("Input : {s}\n", .{buf});
        return null;
    };

    if (user_input == null) {
        print("Bad Input. Could not parse.\n", .{});
        return null;
    }
    if (user_input.?.len == 0 or user_input.?.len > 3) {
        print("Bad Input : {s} Length = {}\n", .{ user_input.?, user_input.?.len });
        return null;
    }
    const column = std.fmt.parseInt(u8, user_input.?[0..1], 255) catch {
        print("Bad Column input\n", .{});
        return null;
    };
    const row = std.fmt.parseInt(u8, user_input.?[1..2], 255) catch {
        print("Bad Row input\n", .{});
        return null;
    };
    return Square{ .column = column, .row = row };
}

fn validateMove(validMoves: []Square, move: Square) ?Square {
    for (validMoves) |validMove| {
        if (move.column == validMove.column and move.row == validMove.row) {
            return validMove;
        }
    }
    return null;
}
