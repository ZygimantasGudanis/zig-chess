const std = @import("std");
pub const ChessSide = enum { Black, White };
pub const ChessPiece = enum { Pawn, Bishop, Knight, Rook, Queen, King };

pub const Piece = struct {
    hasMoved: bool = false,
    side: ChessSide,
    piece: ChessPiece,

    pub fn isWhite(self: Piece) bool {
        return self.side == ChessSide.White;
    }

    pub fn symbols(self: Piece) []const u8 {
        switch (self.piece) {
            .Bishop => return "B",
            .King => return "K",
            .Knight => return "N",
            .Pawn => return "P",
            .Queen => return "Q",
            .Rook => return "R",
        }
    }
};
