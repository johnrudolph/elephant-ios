import SwiftUI

@Observable
final class GameViewModel {
    private(set) var game: GameState
    private(set) var isAnimating = false
    private let audio = AudioManager.shared

    // Turn timer
    static let turnDuration: TimeInterval = 35
    static let urgentThreshold: TimeInterval = 10
    private(set) var turnTimeRemaining: TimeInterval = turnDuration
    private var timerTask: Task<Void, Never>?

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

    var timerProgress: Double {
        turnTimeRemaining / Self.turnDuration
    }

    var isTimerUrgent: Bool {
        turnTimeRemaining <= Self.urgentThreshold
    }

    var showTimer: Bool {
        isPlayerTurn && !isComplete
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

    // MARK: - Timer

    func startTimer() {
        stopTimer()
        turnTimeRemaining = Self.turnDuration
        timerTask = Task { @MainActor in
            while !Task.isCancelled && turnTimeRemaining > 0 {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                turnTimeRemaining -= 0.1
                if turnTimeRemaining <= 0 {
                    handleTimerExpired()
                    return
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func resetTimer() {
        stopTimer()
        if isPlayerTurn {
            startTimer()
        }
    }

    private func handleTimerExpired() {
        guard !isComplete else { return }
        // Forfeit — opponent wins
        game.status = .complete
        game.victorIds = [game.opponent.id]
        stopTimer()
        playEndGameSound()
    }

    // MARK: - Actions

    func placeTile(slide: Slide) {
        guard isPlayerTurn, isTilePhase else { return }
        stopTimer()
        isAnimating = true
        game = GameEngine.placeTile(slide: slide, game: game)
        audio.playSlide()

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            if isComplete {
                playEndGameSound()
            }
        }
    }

    func moveElephant(to space: Int) {
        guard isPlayerTurn, isElephantPhase else { return }
        let previousSpace = elephantSpace
        stopTimer()
        isAnimating = true
        game = GameEngine.moveElephant(to: space, game: game)
        if space != previousSpace { audio.playElephant() }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            if !isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            } else if isPlayerTurn {
                startTimer()
            }
        }
    }

    func executeBotTurn() {
        guard game.currentPlayer.isBot, !isComplete else { return }
        stopTimer()
        isAnimating = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(Int.random(in: 500...1000)))

            guard let move = BotAI.selectMove(game: game) else {
                isAnimating = false
                return
            }

            game = GameEngine.placeTile(slide: move.slide, game: game)
            audio.playSlide()
            try? await Task.sleep(for: .milliseconds(700))

            guard !isComplete else {
                isAnimating = false
                playEndGameSound()
                return
            }

            let prevElephant = game.board.elephantSpace
            game = GameEngine.moveElephant(to: move.elephantMove, game: game)
            if move.elephantMove != prevElephant { audio.playElephant() }
            try? await Task.sleep(for: .milliseconds(700))

            isAnimating = false

            if !isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            } else if isPlayerTurn {
                startTimer()
            }
        }
    }

    func startNewBotGame() {
        stopTimer()
        let playerId = game.player1.id
        let playerName = game.player1.name
        game = GameEngine.newBotGame(playerId: playerId, playerName: playerName)
        if isPlayerTurn {
            startTimer()
        }
    }

    private func playEndGameSound() {
        stopTimer()
        if victorIds.contains(game.player1.id) {
            audio.playVictory()
        } else if !victorIds.isEmpty {
            audio.playDefeat()
        }
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
