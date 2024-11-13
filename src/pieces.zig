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
            // .ChessPawn => |p| return p.canMove(),
            // .ChessBishop => |p| return p.canMove(),
            // .ChessKnight => |p| return p.canMove(),
            // .ChessRook => |p| return p.canMove(),
            // .ChessQueen => |p| return p.canMove(),
            // .ChessKing => |p| return p.canMove(),
        }
    }
};

pub const ChessPawn = struct {
    side: Side,
    pub fn canMove(_: ChessPawn) bool {
        return true;
    }
};

pub const ChessBishop = struct {
    side: Side,
    pub fn canMove(_: ChessBishop) bool {
        return true;
    }
};

pub const ChessRook = struct {
    side: Side,
    pub fn canMove(_: ChessRook) bool {
        return true;
    }
};

pub const ChessKnight = struct {
    side: Side,
    pub fn canMove(_: ChessKnight) bool {
        return true;
    }
};

pub const ChessQueen = struct {
    side: Side,
    pub fn canMove(_: ChessQueen) bool {
        return true;
    }
};

pub const ChessKing = struct {
    side: Side,
    pub fn canMove(_: ChessKing) bool {
        return true;
    }
};
