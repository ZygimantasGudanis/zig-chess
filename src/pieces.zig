const std = @import("std");
pub const Side = enum { Black, White, empty };

pub const Piece = union(enum) {
    pawn: ChessPawn,
    bishop: ChessBishop,
    empty: ChessEmpty,
    knight: ChessKnight,
    rook: ChessRook,
    queen: ChessQueen,
    king: ChessKing,
    pub fn canMove(self: Piece) bool {
        switch (self) {
            inline else => |case| return case.canMove(),
            // .ChessPawn => |p| return p.canMove(),
            // .ChessBishop => |p| return p.canMove(),
            // .ChessKnight => |p| return p.canMove(),
            // .ChessRook => |p| return p.canMove(),
            // .ChessQueen => |p| return p.canMove(),
            // .ChessKing => |p| return p.canMove(),
        }
    }
    pub fn name(self: Piece) []const u8 {
        switch (self) {
            inline else => |case| return case.name(),
            // .ChessPawn => |p| return p.canMove(),
            // .ChessBishop => |p| return p.canMove(),
            // .ChessKnight => |p| return p.canMove(),
            // .ChessRook => |p| return p.canMove(),
            // .ChessQueen => |p| return p.canMove(),
            // .ChessKing => |p| return p.canMove(),
        }
    }
};

pub const ChessEmpty = struct {
    //symbol: u8 = "P",
    side: Side,

    pub fn canMove(_: ChessEmpty) bool {
        return false;
    }
    pub fn name(_: ChessEmpty) []const u8 {
        return " ";
    }
};

pub const ChessPawn = struct {
    //symbol: u8 = "P",
    side: Side,

    pub fn canMove(_: ChessPawn) bool {
        return true;
    }
    pub fn name(_: ChessPawn) []const u8 {
        return "P";
    }
};

pub const ChessBishop = struct {
    //symbol: u8 = "B",
    side: Side,
    pub fn canMove(_: ChessBishop) bool {
        return true;
    }
    pub fn name(_: ChessBishop) []const u8 {
        return "B";
    }
};

pub const ChessRook = struct {
    //symbol: u8 = "O",
    side: Side,
    pub fn canMove(_: ChessRook) bool {
        return true;
    }
    pub fn name(_: ChessRook) []const u8 {
        return "R";
    }
};

pub const ChessKnight = struct {
    //symbol: u8 = "N",
    side: Side,
    pub fn canMove(_: ChessKnight) bool {
        return true;
    }
    pub fn name(_: ChessKnight) []const u8 {
        return "N";
    }
};

pub const ChessQueen = struct {
    //symbol: u8 = "Q",
    side: Side,
    pub fn canMove(_: ChessQueen) bool {
        return true;
    }
    pub fn name(_: ChessQueen) []const u8 {
        return "Q";
    }
};

pub const ChessKing = struct {
    //symbol: u8 = "K",
    side: Side,
    pub fn canMove(_: ChessKing) bool {
        return true;
    }

    pub fn name(_: ChessKing) []const u8 {
        return "K";
    }
};
