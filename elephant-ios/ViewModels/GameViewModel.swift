import SwiftUI

@Observable
final class GameViewModel {
    private(set) var game: GameState
    private(set) var isAnimating = false
    private let audio = AudioManager.shared

    // Tutorial
    var tutorial: TutorialManager?
    var isTutorialMode: Bool { tutorial != nil && !(tutorial?.isComplete ?? true) }

    // Blocked move feedback
    private(set) var blockedFeedbackActive = false
    private(set) var blockedPath: [Int] = []

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
        let engineSlides = ElephantLogic.validSlides(board: board)

        // In tutorial mode with a forced slide, only allow that one
        if let tutorial, !tutorial.isComplete, let forced = tutorial.forcedSlide {
            return engineSlides.filter { $0 == forced }
        }
        return engineSlides
    }

    var validElephantMoves: [Int] {
        guard isElephantPhase, isPlayerTurn else { return [] }
        let engineMoves = ElephantLogic.validMoves(from: elephantSpace)

        if let tutorial, !tutorial.isComplete, let forced = tutorial.forcedElephantMove {
            return engineMoves.filter { $0 == forced }
        }
        return engineMoves
    }

    var timerProgress: Double {
        turnTimeRemaining / Self.turnDuration
    }

    var isTimerUrgent: Bool {
        turnTimeRemaining <= Self.urgentThreshold
    }

    var isBotGame: Bool {
        game.player1.isBot || game.player2.isBot
    }

    var timerAllowed: Bool {
        !isTutorialMode && !isBotGame && UserPreferences.turnTimerEnabled
    }

    var showTimer: Bool {
        timerAllowed && isPlayerTurn && !isComplete
    }

    var statusText: String {
        // In tutorial mode, use tutorial text
        if let tutorial, !tutorial.isComplete {
            if tutorial.showingBotMessage, let msg = tutorial.currentStep.afterBotText {
                return msg
            }
            return tutorial.currentStep.instructionText
        }

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

    init(game: GameState, tutorial: TutorialManager? = nil) {
        self.game = game
        self.tutorial = tutorial
    }

    // MARK: - Blocked Move Feedback

    /// Attempt a slide — if blocked, show visual feedback. Returns true if the move was executed.
    func attemptSlide(slide: Slide) {
        let allValid = ElephantLogic.validSlides(board: board)

        if allValid.contains(slide) {
            // Valid move — but is it allowed in tutorial?
            if let tutorial, !tutorial.isComplete {
                if let forced = tutorial.forcedSlide, slide != forced {
                    // Not the forced move — don't execute, but no blocked feedback
                    return
                }
                // It's a "try blocked" step — the slide shouldn't be valid here
                // (handled below)
            }
            placeTile(slide: slide)
        } else {
            // Blocked! Show feedback
            showBlockedFeedback(slide: slide)

            // In tutorial, advance past the blocked step
            if let tutorial, !tutorial.isComplete, tutorial.blockedSlideToTry != nil {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(800))
                    tutorial.advancePastBlock()
                }
            }
        }
    }

    private func showBlockedFeedback(slide: Slide) {
        let path = slide.path
        guard !path.isEmpty else { return }

        // Find which spaces in the path are relevant to the block
        var blocked: [Int] = []
        for space in path {
            if board.elephantSpace == space {
                blocked.append(space)
                break
            }
            if board.isOccupied(space) {
                blocked.append(space)
            }
        }
        if blocked.isEmpty {
            blocked = [board.elephantSpace]
        }

        blockedPath = blocked
        blockedFeedbackActive = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            blockedFeedbackActive = false
            blockedPath = []
        }
    }

    // MARK: - Timer

    func startTimer() {
        guard timerAllowed else { return }
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

    private func handleTimerExpired() {
        guard !isComplete else { return }
        game.status = .complete
        game.victorIds = [game.opponent.id]
        stopTimer()
        playEndGameSound()
    }

    // MARK: - Actions

    func placeTile(slide: Slide) {
        guard isPlayerTurn, isTilePhase else { return }
        guard validSlides.contains(slide) else { return }
        stopTimer()
        isAnimating = true
        game = GameEngine.placeTile(slide: slide, game: game)
        audio.playSlide()

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            if isComplete {
                playEndGameSound()
                return
            }

            // Tutorial: advance after player places tile
            if let tutorial, !tutorial.isComplete {
                tutorial.advance()
            }
        }
    }

    func moveElephant(to space: Int) {
        guard isPlayerTurn, isElephantPhase else { return }
        guard validElephantMoves.contains(space) else { return }
        let previousSpace = elephantSpace
        stopTimer()
        isAnimating = true
        game = GameEngine.moveElephant(to: space, game: game)
        if space != previousSpace { audio.playElephant() }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(700))
            isAnimating = false

            // Tutorial: advance after player moves elephant
            if let tutorial, !tutorial.isComplete {
                tutorial.advance()
                // If next step is a bot turn, execute it
                if !tutorial.isComplete && !tutorial.currentStep.isPlayerTurn {
                    executeTutorialBotTurn()
                }
                return
            }

            if !isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            } else if isPlayerTurn {
                startTimer()
            }
        }
    }

    // MARK: - Bot Turns

    func executeBotTurn() {
        guard game.currentPlayer.isBot, !isComplete else { return }
        stopTimer()
        isAnimating = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(Int.random(in: 500...1000)))

            let difficulty: BotDifficulty = (tutorial?.isComplete == true) ? .easy : .hard
            guard let move = BotAI.selectMove(game: game, difficulty: difficulty) else {
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

    private func executeTutorialBotTurn() {
        guard let tutorial, let move = tutorial.scriptedBotMove else { return }
        isAnimating = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(800))

            game = GameEngine.placeTile(slide: move.slide, game: game)
            audio.playSlide()
            try? await Task.sleep(for: .milliseconds(700))

            guard !isComplete else {
                isAnimating = false
                return
            }

            let prevElephant = game.board.elephantSpace
            game = GameEngine.moveElephant(to: move.elephantMove, game: game)
            if move.elephantMove != prevElephant { audio.playElephant() }
            try? await Task.sleep(for: .milliseconds(700))

            isAnimating = false

            // Show bot message, then advance
            tutorial.showBotMessage()
            try? await Task.sleep(for: .milliseconds(2000))
            tutorial.advance()
        }
    }

    // MARK: - Game Management

    func startNewBotGame() {
        stopTimer()
        let playerId = game.player1.id
        let playerName = game.player1.name
        tutorial = nil
        game = GameEngine.newBotGame(playerId: playerId, playerName: playerName)
        if isPlayerTurn {
            startTimer()
        }
    }

    func advanceTutorialInfo() {
        // For info-only steps (showVictoryShape, explainTiles), advance on tap
        guard let tutorial, !tutorial.isComplete else { return }
        let step = tutorial.currentStep
        if step == .showVictoryShape || step == .explainTiles {
            tutorial.advance()
            // If tutorial is now complete (freePlay), the game continues with easy bot
            if tutorial.isComplete && game.currentPlayer.isBot {
                executeBotTurn()
            }
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
