import Foundation

enum TutorialStep: Int, CaseIterable {
    case slideDown2             // "Swipe down to slide a tile onto the board"
    case moveElephantTo5        // "Now move the elephant"
    case botPlays16             // Bot places tile at space 16
    case tryBlockedRight5       // Player tries to slide right (elephant blocks at 5)
    case slideDown1             // "Try sliding here instead"
    case moveElephantTo6        // "Move the elephant back"
    case botPushes              // Bot slides right from 1, pushes player tiles
    case tryBlockedDown2        // Player tries slide down col 2 (tile + elephant blocks)
    case showVictoryShape       // Highlight victory shape, explain win condition
    case explainTiles           // Explain hand count and push-off
    case freePlay               // Release to easy mode bot

    var isPlayerTurn: Bool {
        switch self {
        case .slideDown2, .moveElephantTo5,
             .tryBlockedRight5, .slideDown1,
             .moveElephantTo6,
             .tryBlockedDown2,
             .showVictoryShape, .explainTiles, .freePlay:
            return true
        case .botPlays16, .botPushes:
            return false
        }
    }

    var isTilePhase: Bool {
        switch self {
        case .slideDown2, .tryBlockedRight5, .slideDown1,
             .tryBlockedDown2, .freePlay:
            return true
        default:
            return false
        }
    }

    var instructionText: String {
        switch self {
        case .slideDown2:
            return "Swipe down to slide a tile onto the board!"
        case .moveElephantTo5:
            return "Now tap to move the elephant."
        case .botPlays16:
            return ""
        case .tryBlockedRight5:
            return "Try swiping right on this row."
        case .slideDown1:
            return "The elephant blocked you! Try swiping down here instead."
        case .moveElephantTo6:
            return "Move the elephant back."
        case .botPushes:
            return ""
        case .tryBlockedDown2:
            return "Try swiping down on this column."
        case .showVictoryShape:
            return "See the shape next to your name? Arrange 4 tiles into that shape to win!"
        case .explainTiles:
            return "You have 8 tiles. If a tile gets pushed off the board, it returns to your hand."
        case .freePlay:
            return ""
        }
    }

    var afterBotText: String? {
        switch self {
        case .botPlays16:
            return "Your opponent placed a tile. Your turn!"
        case .botPushes:
            return "Your opponent pushed your tiles! Tiles cascade when spaces are occupied."
        default:
            return nil
        }
    }

    /// The space to highlight for the player's attention (for slide hint arrows)
    var highlightHint: TutorialHighlight? {
        switch self {
        case .slideDown2:
            return .slideArrow(space: 2, direction: .down)
        case .moveElephantTo5:
            return .elephantTarget(space: 5)
        case .tryBlockedRight5:
            return .slideArrow(space: 5, direction: .right)
        case .slideDown1:
            return .slideArrow(space: 1, direction: .down)
        case .moveElephantTo6:
            return .elephantTarget(space: 6)
        case .tryBlockedDown2:
            return .slideArrow(space: 2, direction: .down)
        case .showVictoryShape:
            return .victoryShape
        case .explainTiles:
            return .handCount
        default:
            return nil
        }
    }
}

enum TutorialHighlight: Equatable {
    case slideArrow(space: Int, direction: Direction)
    case elephantTarget(space: Int)
    case victoryShape
    case handCount
}

@Observable
final class TutorialManager {
    private(set) var currentStep: TutorialStep = .slideDown2
    private(set) var showingBotMessage = false
    var isComplete: Bool { currentStep == .freePlay }

    /// The only slide allowed in the current step (nil = any / not a slide step)
    var forcedSlide: Slide? {
        switch currentStep {
        case .slideDown2:
            return Slide(entrySpace: 2, direction: .down)
        case .slideDown1:
            return Slide(entrySpace: 1, direction: .down)
        default:
            return nil
        }
    }

    /// The "try this blocked move" slide for feedback steps
    var blockedSlideToTry: Slide? {
        switch currentStep {
        case .tryBlockedRight5:
            return Slide(entrySpace: 5, direction: .right)
        case .tryBlockedDown2:
            return Slide(entrySpace: 2, direction: .down)
        default:
            return nil
        }
    }

    /// The only elephant move allowed
    var forcedElephantMove: Int? {
        switch currentStep {
        case .moveElephantTo5: return 5
        case .moveElephantTo6: return 6
        default: return nil
        }
    }

    /// Get the bot's scripted move for the current step
    var scriptedBotMove: BotMove? {
        switch currentStep {
        case .botPlays16:
            // Bot slides left from entry 16, path [16, 15, 14, 13], tile at 16
            // Bot keeps elephant at 5 (stay in place)
            return BotMove(
                slide: Slide(entrySpace: 16, direction: .left),
                elephantMove: 5
            )
        case .botPushes:
            // Bot slides right from entry 1, path [1, 2, 3, 4]
            // Pushes player tiles at 1 and 2 → cascade
            // Bot keeps elephant at 6
            return BotMove(
                slide: Slide(entrySpace: 1, direction: .right),
                elephantMove: 6
            )
        default:
            return nil
        }
    }

    func advance() {
        let allSteps = TutorialStep.allCases
        guard let currentIndex = allSteps.firstIndex(of: currentStep),
              currentIndex + 1 < allSteps.count else { return }
        showingBotMessage = false
        currentStep = allSteps[currentIndex + 1]
    }

    /// After a "try blocked" step fails, advance to the next step
    func advancePastBlock() {
        advance()
    }

    func showBotMessage() {
        showingBotMessage = true
    }

    /// Create the tutorial game state
    static func createTutorialGame(playerId: String, playerName: String) -> GameState {
        GameState(
            id: UUID(),
            status: .active,
            board: .empty,
            phase: .placeTile,
            currentPlayerId: playerId,
            player1: PlayerState.newPlayer(id: playerId, name: playerName),
            player2: PlayerState.bot(),
            victorIds: [],
            winningSpaces: [],
            victoryShape: .square,
            isRanked: false,
            moves: []
        )
    }
}
