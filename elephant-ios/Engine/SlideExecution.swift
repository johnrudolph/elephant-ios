import Foundation

struct SlideResult {
    var board: Board
    var pushedOffTileOwner: String?
}

enum SlideExecution {
    /// Execute a slide on the board, placing a tile for the given player.
    ///
    /// The new tile enters at the entry space. If the entry is occupied,
    /// the occupant cascades to the next space, and so on — but only
    /// through contiguous occupied spaces from the entry point.
    /// A tile at the far end gets pushed off the board.
    static func execute(slide: Slide, playerId: String, board: Board) -> SlideResult {
        let path = slide.path
        guard path.count == 4 else {
            return SlideResult(board: board, pushedOffTileOwner: nil)
        }

        var newBoard = board
        var pushedOff: String? = nil

        // Find how many contiguous occupied spaces from the entry
        var cascadeLength = 0
        for i in 0..<path.count {
            if board.isOccupied(path[i]) {
                cascadeLength += 1
            } else {
                break
            }
        }

        // If all 4 are occupied, the tile at position 3 is pushed off
        if cascadeLength == 4 {
            pushedOff = board.owner(of: path[3])
            cascadeLength = 3 // only shift 3 tiles (the 4th falls off)
        }

        // Shift the contiguous tiles by one position (back to front)
        for i in stride(from: cascadeLength, through: 1, by: -1) {
            newBoard.spaces[path[i]] = board.owner(of: path[i - 1])
        }

        // Place the new tile at entry
        newBoard.spaces[path[0]] = playerId

        return SlideResult(board: newBoard, pushedOffTileOwner: pushedOff)
    }
}
