import Foundation

enum GameEngine {
    /// Create a new bot game.
    static func newBotGame(playerId: String, playerName: String, playerGoesFirst: Bool = true) -> GameState {
        let shape = VictoryShape.botShapes.randomElement()!
        let player1 = PlayerState.newPlayer(id: playerId, name: playerName)
        let player2 = PlayerState.bot()

        return GameState(
            id: UUID(),
            status: .active,
            board: .empty,
            phase: .placeTile,
            currentPlayerId: playerGoesFirst ? playerId : PlayerState.botId,
            player1: player1,
            player2: player2,
            victorIds: [],
            winningSpaces: [],
            victoryShape: shape,
            isRanked: false,
            moves: []
        )
    }

    /// Place a tile on the board via a slide.
    /// Returns the updated game state. Victory is checked after placement.
    static func placeTile(slide: Slide, game: GameState) -> GameState {
        guard game.status == .active,
              game.phase == .placeTile else { return game }

        let validSlides = ElephantLogic.validSlides(board: game.board)
        guard validSlides.contains(slide) else { return game }

        var state = game
        let playerId = state.currentPlayerId

        let boardBefore = state.board
        let result = SlideExecution.execute(slide: slide, playerId: playerId, board: state.board)
        state.board = result.board

        // Decrement current player's hand
        var currentPlayer = state.currentPlayer
        currentPlayer.hand -= 1
        state.updatePlayer(currentPlayer)

        // If a tile was pushed off, return it to its owner's hand
        if let pushedOwner = result.pushedOffTileOwner {
            if var owner = state.player(for: pushedOwner) {
                owner.hand += 1
                state.updatePlayer(owner)
            }
        }

        // Record the move
        state.moves.append(MoveRecord(
            playerId: playerId,
            type: .tile,
            boardBefore: boardBefore,
            boardAfter: state.board,
            slide: slide
        ))

        // Check for victory (after tile placement, before elephant move)
        let victories = VictoryDetection.checkBoth(
            player1Id: state.player1.id,
            player2Id: state.player2.id,
            shape: state.victoryShape,
            board: state.board
        )

        if !victories.isEmpty {
            state.status = .complete
            state.victorIds = victories.map(\.playerId)
            state.winningSpaces = victories.flatMap(\.winningSpaces)
            return state
        }

        // Check for draw: both players out of tiles and no victory
        if state.player1.hand == 0 && state.player2.hand == 0 {
            state.status = .complete
            return state
        }

        // Move to elephant phase
        state.phase = .moveElephant

        return state
    }

    /// Move the elephant to a new space (or same space to stay).
    /// After moving, the turn passes to the opponent (unless opponent has no tiles).
    static func moveElephant(to space: Int, game: GameState) -> GameState {
        guard game.status == .active,
              game.phase == .moveElephant else { return game }

        let validMoves = ElephantLogic.validMoves(from: game.board.elephantSpace)
        guard validMoves.contains(space) else { return game }

        var state = game
        let boardBefore = state.board

        state.board.elephantSpace = space

        // Record the move
        state.moves.append(MoveRecord(
            playerId: state.currentPlayerId,
            type: .elephant,
            boardBefore: boardBefore,
            boardAfter: state.board,
            slide: nil
        ))

        // Switch turns
        state.phase = .placeTile
        let opponentId = state.opponent.id

        if let opponent = state.player(for: opponentId), opponent.hand > 0 {
            state.currentPlayerId = opponentId
        }
        // If opponent has no tiles, current player keeps going

        return state
    }
}
