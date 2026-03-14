import Foundation

enum GamePhase: String, Codable {
    case placeTile
    case moveElephant
}

enum GameStatus: String, Codable {
    case created, active, complete, canceled
}

struct GameState: Codable, Equatable {
    let id: UUID
    var status: GameStatus
    var board: Board
    var phase: GamePhase
    var currentPlayerId: String
    var player1: PlayerState
    var player2: PlayerState
    var victorIds: [String]
    var winningSpaces: [Int]
    var victoryShape: VictoryShape
    var isRanked: Bool
    var moves: [MoveRecord]

    var isComplete: Bool { status == .complete }

    var currentPlayer: PlayerState {
        currentPlayerId == player1.id ? player1 : player2
    }

    var opponent: PlayerState {
        currentPlayerId == player1.id ? player2 : player1
    }

    func player(for id: String) -> PlayerState? {
        if id == player1.id { return player1 }
        if id == player2.id { return player2 }
        return nil
    }

    mutating func updatePlayer(_ player: PlayerState) {
        if player.id == player1.id {
            player1 = player
        } else if player.id == player2.id {
            player2 = player
        }
    }
}
