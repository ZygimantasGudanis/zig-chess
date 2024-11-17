const std = @import("std");
pub const Side = enum { Black, White };

pub const Piece = union(enum) {
    pawn: ChessPawn,
    bishop: ChessBishop,
    knight: ChessKnight,
    rook: ChessRook,
    queen: ChessQueen,
    king: ChessKing,
    pub fn canMove(self: Piece) bool {
        switch (self) {
            inline else => |case| return case.canMove(),
        }
    }
    pub fn name(self: Piece) []const u8 {
        switch (self) {
            inline else => |case| return case.symbol,
        }
    }
    pub fn isWhite(self: Piece) bool {
        switch (self) {
            inline else => |case| return case.side == Side.White,
        }
    }
    pub fn sideOf(self: Piece) Side {
        switch (self) {
            inline else => |case| return case.side,
        }
    }
};

pub const ChessPawn = struct {
    symbol: []const u8 = "P",
    side: Side,
    hasMoved: bool = false,
    pub fn canMove(_: ChessPawn) bool {
        return true;
    }
};

pub const ChessBishop = struct {
    symbol: []const u8 = "B",
    side: Side,
    hasMoved: bool = false,

    pub fn canMove(_: ChessBishop) bool {
        return true;
    }
};

pub const ChessRook = struct {
    symbol: []const u8 = "R",
    side: Side,
    hasMoved: bool = false,
    pub fn canMove(_: ChessRook) bool {
        return true;
    }
};

pub const ChessKnight = struct {
    symbol: []const u8 = "N",
    side: Side,
    pub fn canMove(_: ChessKnight) bool {
        return true;
    }
};

pub const ChessQueen = struct {
    symbol: []const u8 = "Q",
    side: Side,
    pub fn canMove(_: ChessQueen) bool {
        return true;
    }
};

pub const ChessKing = struct {
    symbol: []const u8 = "K",
    side: Side,
    hasMoved: bool = false,
    pub fn canMove(_: ChessKing) bool {
        return true;
    }
};
