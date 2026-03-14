import Foundation

enum BotDifficulty {
    case easy   // picks from top 3
    case medium // picks from top 2
    case hard   // always picks best
}

struct BotMove {
    let slide: Slide
    let elephantMove: Int
}

enum BotAI {

    /// Select a full move (slide + elephant placement) for the bot.
    static func selectMove(game: GameState, difficulty: BotDifficulty = .hard) -> BotMove? {
        let botId = game.currentPlayerId
        let opponentId = game.opponent.id
        let validSlides = ElephantLogic.validSlides(board: game.board)
        guard !validSlides.isEmpty else { return nil }

        // Score all valid slides
        var scored: [(slide: Slide, score: Int)] = validSlides.shuffled().map { slide in
            let result = SlideExecution.execute(slide: slide, playerId: botId, board: game.board)
            let score = boardScore(
                board: result.board,
                botId: botId,
                opponentId: opponentId,
                shape: game.victoryShape,
                botHand: game.currentPlayer.hand - 1,
                pushedOffOwner: result.pushedOffTileOwner
            )
            return (slide, score)
        }

        // Sort by score descending
        scored.sort { $0.score > $1.score }

        // Select based on difficulty
        let topN: Int = switch difficulty {
        case .hard: 1
        case .medium: min(2, scored.count)
        case .easy: min(3, scored.count)
        }
        let selected = scored[0..<topN].randomElement()!

        // Pick elephant move (currently random among valid moves)
        let afterSlide = SlideExecution.execute(
            slide: selected.slide, playerId: botId, board: game.board
        )
        let validElephantMoves = ElephantLogic.validMoves(from: afterSlide.board.elephantSpace)
        let elephantMove = validElephantMoves.randomElement()!

        return BotMove(slide: selected.slide, elephantMove: elephantMove)
    }

    // MARK: - Scoring

    static func boardScore(
        board: Board,
        botId: String,
        opponentId: String,
        shape: VictoryShape,
        botHand: Int,
        pushedOffOwner: String?
    ) -> Int {
        var score = 0

        // Victory checks
        if VictoryDetection.check(playerId: botId, shape: shape, board: board) != nil {
            score += 1_000_000_000
        }
        if VictoryDetection.check(playerId: opponentId, shape: shape, board: board) != nil {
            score -= 1_000
        }

        // Check detection (3 of 4 tiles toward victory)
        if hasCheck(playerId: botId, shape: shape, board: board) {
            score += 100
        }
        if hasCheck(playerId: opponentId, shape: shape, board: board) {
            score -= 200
        }

        // Adjacency bonuses
        score += adjacentTileCount(for: botId, board: board)
        score -= adjacentTileCount(for: opponentId, board: board)

        // Penalty for running out of tiles
        if botHand <= 0 {
            score -= 500
        }

        return score
    }

    /// Count how many of the player's tiles are adjacent to another of their tiles.
    static func adjacentTileCount(for playerId: String, board: Board) -> Int {
        let spaces = board.spacesOwnedBy(playerId)
        let spaceSet = Set(spaces)
        var count = 0
        for space in spaces {
            for adj in Board.adjacentSpaces(of: space) {
                if spaceSet.contains(adj) {
                    count += 1
                }
            }
        }
        // Each adjacency is counted twice (A→B and B→A), divide by 2
        return count / 2
    }

    /// Check if the player has "check" — 3 out of 4 tiles of any victory configuration,
    /// with the 4th space empty (not occupied by opponent).
    static func hasCheck(playerId: String, shape: VictoryShape, board: Board) -> Bool {
        let playerSpaces = Set(board.spacesOwnedBy(playerId))
        guard playerSpaces.count >= 3 else { return false }

        for config in shape.configurations {
            let matching = config.filter { playerSpaces.contains($0) }
            if matching.count == 3 {
                // The 4th space must be empty (not blocked by opponent or elephant)
                let missing = config.first { !playerSpaces.contains($0) }!
                if board.isEmpty(missing) && board.elephantSpace != missing {
                    return true
                }
            }
        }
        return false
    }
}
