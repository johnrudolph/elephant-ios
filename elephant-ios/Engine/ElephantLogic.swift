import Foundation

enum ElephantLogic {
    /// Returns all valid spaces the elephant can move to (adjacent + current).
    static func validMoves(from space: Int) -> [Int] {
        var moves = Board.adjacentSpaces(of: space)
        moves.append(space) // staying in place is always valid
        return moves
    }

    /// Returns true if the elephant blocks the given slide on the given board.
    ///
    /// The elephant blocks a slide if it sits at any position in the path
    /// where a tile would need to move. Specifically:
    /// - Elephant at position 0 (entry): always blocks
    /// - Elephant at position N: blocks if positions 0..(N-1) are all occupied
    static func slideIsBlocked(slide: Slide, board: Board) -> Bool {
        let path = slide.path
        guard !path.isEmpty else { return true }

        for (index, space) in path.enumerated() {
            if board.elephantSpace == space {
                if index == 0 {
                    return true
                }
                // Elephant at this position blocks if all preceding positions are occupied
                let precedingAllOccupied = path[0..<index].allSatisfy { board.isOccupied($0) }
                if precedingAllOccupied {
                    return true
                }
            }
        }
        return false
    }

    /// Returns all slides that are not blocked by the elephant.
    static func validSlides(board: Board) -> [Slide] {
        Slide.allSlides.filter { !slideIsBlocked(slide: $0, board: board) }
    }
}
