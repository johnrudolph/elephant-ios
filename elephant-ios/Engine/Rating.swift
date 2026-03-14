import Foundation

enum GameResult {
    case win, loss, draw
}

enum Rating {
    static let kFactor = 32.0
    static let startingRating = 1000
    static let minRating = 100
    static let maxRating = 3000

    static func calculateNewRating(
        playerRating: Int,
        opponentRating: Int,
        result: GameResult
    ) -> Int {
        let expected = 1.0 / (1.0 + pow(10.0, Double(opponentRating - playerRating) / 400.0))
        let actual: Double = switch result {
        case .win: 1.0
        case .loss: 0.0
        case .draw: 0.5
        }
        let newRating = Double(playerRating) + kFactor * (actual - expected)
        return max(minRating, min(maxRating, Int(newRating.rounded())))
    }
}
