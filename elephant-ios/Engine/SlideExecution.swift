import Foundation

struct SlideResult {
    var board: Board
    var pushedOffTileOwner: String? // player ID of tile pushed off, if any
}

enum SlideExecution {
    /// Execute a slide on the board, placing a tile for the given player.
    ///
    /// The new tile enters at the entry space and pushes existing tiles along the path.
    /// If all 4 positions are occupied, the tile at the far end is pushed off and
    /// returns to its owner's hand.
    static func execute(slide: Slide, playerId: String, board: Board) -> SlideResult {
        let path = slide.path
        guard path.count == 4 else {
            return SlideResult(board: board, pushedOffTileOwner: nil)
        }

        var newBoard = board
        var pushedOff: String? = nil

        // Check if tile at position 4 (far end) gets pushed off
        if path.allSatisfy({ board.isOccupied($0) }) {
            pushedOff = board.owner(of: path[3])
        }

        // Cascade: shift tiles from back to front
        // Work backwards through the path
        for i in stride(from: path.count - 1, through: 1, by: -1) {
            newBoard.spaces[path[i]] = board.owner(of: path[i - 1])
        }

        // Place the new tile at entry
        newBoard.spaces[path[0]] = playerId

        return SlideResult(board: newBoard, pushedOffTileOwner: pushedOff)
    }
}
