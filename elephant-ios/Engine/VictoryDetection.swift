import Foundation

struct VictoryResult: Equatable {
    let playerId: String
    let winningSpaces: [Int]
}

enum VictoryDetection {
    /// Check if the given player has achieved the victory shape on the board.
    /// Returns the winning spaces if victorious, nil otherwise.
    static func check(playerId: String, shape: VictoryShape, board: Board) -> VictoryResult? {
        let playerSpaces = Set(board.spacesOwnedBy(playerId))
        guard playerSpaces.count >= 4 else { return nil }

        for config in shape.configurations {
            if config.allSatisfy({ playerSpaces.contains($0) }) {
                return VictoryResult(playerId: playerId, winningSpaces: config)
            }
        }
        return nil
    }

    /// Check both players for victory. Returns results for all winners.
    /// Both players can win simultaneously (draw).
    static func checkBoth(
        player1Id: String,
        player2Id: String,
        shape: VictoryShape,
        board: Board
    ) -> [VictoryResult] {
        var results: [VictoryResult] = []
        if let r1 = check(playerId: player1Id, shape: shape, board: board) {
            results.append(r1)
        }
        if let r2 = check(playerId: player2Id, shape: shape, board: board) {
            results.append(r2)
        }
        return results
    }
}
