import SwiftUI

@Observable
final class GameViewModel {
    private(set) var game: GameState
    private(set) var isAnimating = false

    var board: Board { game.board }
    var elephantSpace: Int { game.board.elephantSpace }
    var phase: GamePhase { game.phase }
    var isComplete: Bool { game.isComplete }
    var currentPlayerId: String { game.currentPlayerId }
    var victoryShape: VictoryShape { game.victoryShape }
    var winningSpaces: [Int] { game.winningSpaces }
    var victorIds: [String] { game.victorIds }

    var isElephantPhase: Bool { phase == .moveElephant && !isAnimating }
    var isTilePhase: Bool { phase == .placeTile && !isAnimating }

    var isPlayerTurn: Bool {
        !game.currentPlayer.isBot && !isAnimating && !isComplete
    }

    var player1: PlayerState { game.player1 }
    var player2: PlayerState { game.player2 }

    var validSlides: [Slide] {
        guard isTilePhase, isPlayerTurn else { return [] }
        return ElephantLogic.validSlides(board: board)
    }

    var validElephantMoves: [Int] {
        guard isElephantPhase, isPlayerTurn else { return [] }
        return ElephantLogic.validMoves(from: elephantSpace)
    }

    var statusText: String {
        if isComplete {
            if victorIds.isEmpty { return "Draw!" }
            if victorIds.count > 1 { return "Draw — both players win!" }
            if victorIds.contains(game.player1.id) { return "You win!" }
            return "You lose!"
        }
        if game.currentPlayer.isBot {
            return "Opponent is thinking..."
        }
        if phase == .placeTile {
            return "Slide a tile onto the board"
        }
        return "Move the elephant"
    }

    init(game: GameState) {
        self.game = game
    }

    // MARK: - Actions

    func placeTile(slide: Slide) {
        guard isPlayerTurn, isTilePhase else { return }
        isAnimating = true
        game = GameEngine.placeTile(slide: slide, game: game)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            if !isComplete {
                // If it's now the elephant phase, wait for player input
                // If game ended, do nothing
            }
        }
    }

    func moveElephant(to space: Int) {
        guard isPlayerTurn, isElephantPhase else { return }
        isAnimating = true
        game = GameEngine.moveElephant(to: space, game: game)

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            if !isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            }
        }
    }

    func executeBotTurn() {
        guard game.currentPlayer.isBot, !isComplete else { return }
        isAnimating = true

        Task { @MainActor in
            // Artificial thinking delay
            try? await Task.sleep(for: .milliseconds(Int.random(in: 500...1000)))

            guard let move = BotAI.selectMove(game: game) else {
                isAnimating = false
                return
            }

            // Place tile
            game = GameEngine.placeTile(slide: move.slide, game: game)
            try? await Task.sleep(for: .milliseconds(700))

            guard !isComplete else {
                isAnimating = false
                return
            }

            // Move elephant
            game = GameEngine.moveElephant(to: move.elephantMove, game: game)
            try? await Task.sleep(for: .milliseconds(700))

            isAnimating = false

            // If bot still has the turn (opponent has no tiles), keep going
            if !isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            }
        }
    }

    func startNewBotGame() {
        let playerId = game.player1.id
        let playerName = game.player1.name
        game = GameEngine.newBotGame(playerId: playerId, playerName: playerName)
    }

    // MARK: - Layout

    func pointForSpace(_ space: Int, cellSize: CGFloat, spacing: CGFloat) -> CGPoint {
        let col = CGFloat(Board.col(of: space))
        let row = CGFloat(Board.row(of: space))
        let x = col * (cellSize + spacing) + cellSize / 2
        let y = row * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }

    func color(for playerId: String) -> Color {
        playerId == game.player1.id ? Color("PlayerOrange") : Color("PlayerTeal")
    }
}
