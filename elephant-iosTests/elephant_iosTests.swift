import XCTest
@testable import elephant_ios

final class BoardTests: XCTestCase {

    func testEmptyBoard() {
        let board = Board.empty
        XCTAssertEqual(board.elephantSpace, 6)
        for space in 1...16 {
            XCTAssertTrue(board.isEmpty(space))
            XCTAssertNil(board.owner(of: space))
        }
    }

    func testRowAndCol() {
        // Space 1 = row 0, col 0
        XCTAssertEqual(Board.row(of: 1), 0)
        XCTAssertEqual(Board.col(of: 1), 0)
        // Space 4 = row 0, col 3
        XCTAssertEqual(Board.row(of: 4), 0)
        XCTAssertEqual(Board.col(of: 4), 3)
        // Space 6 = row 1, col 1
        XCTAssertEqual(Board.row(of: 6), 1)
        XCTAssertEqual(Board.col(of: 6), 1)
        // Space 16 = row 3, col 3
        XCTAssertEqual(Board.row(of: 16), 3)
        XCTAssertEqual(Board.col(of: 16), 3)
    }

    func testSpaceFromRowCol() {
        XCTAssertEqual(Board.space(row: 0, col: 0), 1)
        XCTAssertEqual(Board.space(row: 0, col: 3), 4)
        XCTAssertEqual(Board.space(row: 3, col: 3), 16)
        XCTAssertEqual(Board.space(row: 1, col: 1), 6)
    }

    func testAdjacentSpaces() {
        // Corner: space 1 (top-left)
        let adj1 = Board.adjacentSpaces(of: 1)
        XCTAssertEqual(Set(adj1), Set([2, 5]))

        // Edge: space 2 (top edge)
        let adj2 = Board.adjacentSpaces(of: 2)
        XCTAssertEqual(Set(adj2), Set([1, 3, 6]))

        // Center: space 6
        let adj6 = Board.adjacentSpaces(of: 6)
        XCTAssertEqual(Set(adj6), Set([2, 5, 7, 10]))

        // Corner: space 16 (bottom-right)
        let adj16 = Board.adjacentSpaces(of: 16)
        XCTAssertEqual(Set(adj16), Set([12, 15]))
    }

    func testSpacesOwnedBy() {
        var board = Board.empty
        board.spaces[1] = "p1"
        board.spaces[5] = "p1"
        board.spaces[3] = "p2"
        XCTAssertEqual(Set(board.spacesOwnedBy("p1")), Set([1, 5]))
        XCTAssertEqual(board.spacesOwnedBy("p2"), [3])
        XCTAssertTrue(board.spacesOwnedBy("p3").isEmpty)
    }
}

final class SlideTests: XCTestCase {

    func testAllSlidesCount() {
        XCTAssertEqual(Slide.allSlides.count, 16)
    }

    func testSlidePaths() {
        // Slide down from space 1: path should be [1, 5, 9, 13]
        let slideDown1 = Slide(entrySpace: 1, direction: .down)
        XCTAssertEqual(slideDown1.path, [1, 5, 9, 13])

        // Slide right from space 1: path should be [1, 2, 3, 4]
        let slideRight1 = Slide(entrySpace: 1, direction: .right)
        XCTAssertEqual(slideRight1.path, [1, 2, 3, 4])

        // Slide left from space 4: path should be [4, 3, 2, 1]
        let slideLeft4 = Slide(entrySpace: 4, direction: .left)
        XCTAssertEqual(slideLeft4.path, [4, 3, 2, 1])

        // Slide up from space 13: path should be [13, 9, 5, 1]
        let slideUp13 = Slide(entrySpace: 13, direction: .up)
        XCTAssertEqual(slideUp13.path, [13, 9, 5, 1])

        // Slide down from space 3: path should be [3, 7, 11, 15]
        let slideDown3 = Slide(entrySpace: 3, direction: .down)
        XCTAssertEqual(slideDown3.path, [3, 7, 11, 15])

        // Slide right from space 9: path should be [9, 10, 11, 12]
        let slideRight9 = Slide(entrySpace: 9, direction: .right)
        XCTAssertEqual(slideRight9.path, [9, 10, 11, 12])

        // Slide up from space 16: path should be [16, 12, 8, 4]
        let slideUp16 = Slide(entrySpace: 16, direction: .up)
        XCTAssertEqual(slideUp16.path, [16, 12, 8, 4])

        // Slide left from space 16: path should be [16, 15, 14, 13]
        let slideLeft16 = Slide(entrySpace: 16, direction: .left)
        XCTAssertEqual(slideLeft16.path, [16, 15, 14, 13])
    }

    func testAllPathsHaveFourSpaces() {
        for slide in Slide.allSlides {
            XCTAssertEqual(slide.path.count, 4, "Slide \(slide) should have 4 spaces")
        }
    }

    func testInvalidSlideHasEmptyPath() {
        // Space 6 is not an edge space, direction doesn't matter
        let invalid = Slide(entrySpace: 6, direction: .down)
        XCTAssertTrue(invalid.path.isEmpty)
    }
}

final class ElephantLogicTests: XCTestCase {

    func testValidMoves() {
        // From space 6 (center): adjacent = [2, 5, 7, 10] + stay = [6]
        let moves = ElephantLogic.validMoves(from: 6)
        XCTAssertEqual(Set(moves), Set([2, 5, 6, 7, 10]))

        // From space 1 (corner): adjacent = [2, 5] + stay = [1]
        let cornerMoves = ElephantLogic.validMoves(from: 1)
        XCTAssertEqual(Set(cornerMoves), Set([1, 2, 5]))
    }

    func testElephantBlocksSlideAtEntry() {
        var board = Board.empty
        board.elephantSpace = 1
        let slide = Slide(entrySpace: 1, direction: .down)
        XCTAssertTrue(ElephantLogic.slideIsBlocked(slide: slide, board: board))
    }

    func testElephantBlocksSlideAtPosition2WhenEntryOccupied() {
        var board = Board.empty
        board.spaces[1] = "p1" // entry occupied
        board.elephantSpace = 5  // position 2 in path [1, 5, 9, 13]
        let slide = Slide(entrySpace: 1, direction: .down)
        XCTAssertTrue(ElephantLogic.slideIsBlocked(slide: slide, board: board))
    }

    func testElephantDoesNotBlockWhenGapBeforeIt() {
        var board = Board.empty
        // Path [1, 5, 9, 13], elephant at 9 (position 3)
        // But position 1 (space 1) is empty, so tiles won't reach elephant
        board.elephantSpace = 9
        let slide = Slide(entrySpace: 1, direction: .down)
        XCTAssertFalse(ElephantLogic.slideIsBlocked(slide: slide, board: board))
    }

    func testElephantBlocksWhenAllPrecedingOccupied() {
        var board = Board.empty
        // Path [1, 5, 9, 13], elephant at 9 (position 3)
        board.spaces[1] = "p1"
        board.spaces[5] = "p2"
        board.elephantSpace = 9
        let slide = Slide(entrySpace: 1, direction: .down)
        XCTAssertTrue(ElephantLogic.slideIsBlocked(slide: slide, board: board))
    }

    func testElephantBlocksAtPosition4WhenAllOccupied() {
        var board = Board.empty
        // Path [1, 5, 9, 13], elephant at 13 (position 4)
        board.spaces[1] = "p1"
        board.spaces[5] = "p2"
        board.spaces[9] = "p1"
        board.elephantSpace = 13
        let slide = Slide(entrySpace: 1, direction: .down)
        XCTAssertTrue(ElephantLogic.slideIsBlocked(slide: slide, board: board))
    }

    func testValidSlidesExcludesBlockedOnes() {
        var board = Board.empty
        board.elephantSpace = 1
        let valid = ElephantLogic.validSlides(board: board)
        // Slides entering at space 1 should be blocked
        let blockedSlides = valid.filter { $0.entrySpace == 1 }
        XCTAssertTrue(blockedSlides.isEmpty)
        // Other slides should still be valid
        XCTAssertTrue(valid.count > 0)
    }
}

final class SlideExecutionTests: XCTestCase {

    func testSlideOntoEmptyBoard() {
        let board = Board.empty
        let slide = Slide(entrySpace: 1, direction: .right)
        let result = SlideExecution.execute(slide: slide, playerId: "p1", board: board)
        XCTAssertEqual(result.board.owner(of: 1), "p1")
        XCTAssertNil(result.pushedOffTileOwner)
    }

    func testSlidePushesTile() {
        var board = Board.empty
        board.spaces[1] = "p2" // existing tile at entry
        let slide = Slide(entrySpace: 1, direction: .right) // path: [1, 2, 3, 4]
        let result = SlideExecution.execute(slide: slide, playerId: "p1", board: board)
        XCTAssertEqual(result.board.owner(of: 1), "p1") // new tile at entry
        XCTAssertEqual(result.board.owner(of: 2), "p2") // pushed to position 2
        XCTAssertNil(result.pushedOffTileOwner)
    }

    func testSlideCascadesMultipleTiles() {
        var board = Board.empty
        board.spaces[1] = "p1"
        board.spaces[2] = "p2"
        let slide = Slide(entrySpace: 1, direction: .right) // path: [1, 2, 3, 4]
        let result = SlideExecution.execute(slide: slide, playerId: "p1", board: board)
        XCTAssertEqual(result.board.owner(of: 1), "p1") // new tile
        XCTAssertEqual(result.board.owner(of: 2), "p1") // was at 1
        XCTAssertEqual(result.board.owner(of: 3), "p2") // was at 2
        XCTAssertNil(result.pushedOffTileOwner)
    }

    func testSlidePushesTileOffBoard() {
        var board = Board.empty
        board.spaces[1] = "p1"
        board.spaces[2] = "p2"
        board.spaces[3] = "p1"
        board.spaces[4] = "p2" // position 4 occupied — will be pushed off
        let slide = Slide(entrySpace: 1, direction: .right)
        let result = SlideExecution.execute(slide: slide, playerId: "p1", board: board)
        XCTAssertEqual(result.board.owner(of: 1), "p1") // new tile
        XCTAssertEqual(result.board.owner(of: 2), "p1") // was at 1
        XCTAssertEqual(result.board.owner(of: 3), "p2") // was at 2
        XCTAssertEqual(result.board.owner(of: 4), "p1") // was at 3
        XCTAssertEqual(result.pushedOffTileOwner, "p2") // p2's tile pushed off
    }
}

final class VictoryShapeTests: XCTestCase {

    func testSquareConfigCount() {
        XCTAssertEqual(VictoryShape.square.configurations.count, 9)
    }

    func testLineConfigCount() {
        XCTAssertEqual(VictoryShape.line.configurations.count, 8)
    }

    func testElConfigCount() {
        XCTAssertEqual(VictoryShape.el.configurations.count, 48)
    }

    func testZigConfigCount() {
        XCTAssertEqual(VictoryShape.zig.configurations.count, 24)
    }

    func testPyramidConfigCount() {
        XCTAssertEqual(VictoryShape.pyramid.configurations.count, 24)
    }

    func testAllConfigsHaveFourSpaces() {
        for shape in VictoryShape.allCases {
            for config in shape.configurations {
                XCTAssertEqual(config.count, 4, "\(shape) config should have 4 spaces")
            }
        }
    }

    func testAllConfigSpacesAreValid() {
        for shape in VictoryShape.allCases {
            for config in shape.configurations {
                for space in config {
                    XCTAssertTrue((1...16).contains(space), "\(shape) has invalid space \(space)")
                }
            }
        }
    }

    func testBotShapesExcludeZigAndPyramid() {
        XCTAssertEqual(VictoryShape.botShapes, [.square, .line, .el])
    }
}

final class VictoryDetectionTests: XCTestCase {

    func testNoVictoryOnEmptyBoard() {
        let board = Board.empty
        let result = VictoryDetection.check(playerId: "p1", shape: .square, board: board)
        XCTAssertNil(result)
    }

    func testSquareVictory() {
        var board = Board.empty
        // 2x2 square at top-left: spaces 1, 2, 5, 6
        board.spaces[1] = "p1"
        board.spaces[2] = "p1"
        board.spaces[5] = "p1"
        board.spaces[6] = "p1"
        let result = VictoryDetection.check(playerId: "p1", shape: .square, board: board)
        XCTAssertNotNil(result)
        XCTAssertEqual(Set(result!.winningSpaces), Set([1, 2, 5, 6]))
    }

    func testLineVictoryHorizontal() {
        var board = Board.empty
        for col in 0..<4 {
            board.spaces[Board.space(row: 0, col: col)] = "p1"
        }
        let result = VictoryDetection.check(playerId: "p1", shape: .line, board: board)
        XCTAssertNotNil(result)
        XCTAssertEqual(Set(result!.winningSpaces), Set([1, 2, 3, 4]))
    }

    func testLineVictoryVertical() {
        var board = Board.empty
        for row in 0..<4 {
            board.spaces[Board.space(row: row, col: 2)] = "p2"
        }
        let result = VictoryDetection.check(playerId: "p2", shape: .line, board: board)
        XCTAssertNotNil(result)
        XCTAssertEqual(Set(result!.winningSpaces), Set([3, 7, 11, 15]))
    }

    func testNoVictoryWithOnlyThreeTiles() {
        var board = Board.empty
        board.spaces[1] = "p1"
        board.spaces[2] = "p1"
        board.spaces[5] = "p1"
        // Missing space 6 for square
        let result = VictoryDetection.check(playerId: "p1", shape: .square, board: board)
        XCTAssertNil(result)
    }

    func testSimultaneousVictory() {
        var board = Board.empty
        // P1 has a square at top-left
        board.spaces[1] = "p1"
        board.spaces[2] = "p1"
        board.spaces[5] = "p1"
        board.spaces[6] = "p1"
        // P2 has a square at bottom-right
        board.spaces[11] = "p2"
        board.spaces[12] = "p2"
        board.spaces[15] = "p2"
        board.spaces[16] = "p2"

        let results = VictoryDetection.checkBoth(
            player1Id: "p1", player2Id: "p2", shape: .square, board: board
        )
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.playerId == "p1" }))
        XCTAssertTrue(results.contains(where: { $0.playerId == "p2" }))
    }

    func testWrongPlayerDoesNotWin() {
        var board = Board.empty
        board.spaces[1] = "p1"
        board.spaces[2] = "p1"
        board.spaces[5] = "p1"
        board.spaces[6] = "p1"
        let result = VictoryDetection.check(playerId: "p2", shape: .square, board: board)
        XCTAssertNil(result)
    }
}

final class GameEngineTests: XCTestCase {

    func testNewBotGame() {
        let game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        XCTAssertEqual(game.status, .active)
        XCTAssertEqual(game.phase, .placeTile)
        XCTAssertEqual(game.currentPlayerId, "p1")
        XCTAssertEqual(game.player1.hand, 8)
        XCTAssertEqual(game.player2.hand, 8)
        XCTAssertTrue(game.player2.isBot)
        XCTAssertFalse(game.isRanked)
        XCTAssertTrue(VictoryShape.botShapes.contains(game.victoryShape))
    }

    func testPlaceTileDecrementsHand() {
        let game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        let slide = ElephantLogic.validSlides(board: game.board).first!
        let newGame = GameEngine.placeTile(slide: slide, game: game)
        XCTAssertEqual(newGame.currentPlayer.hand, 8) // opponent's hand unchanged
        // The player who placed the tile now has 7
        XCTAssertEqual(newGame.player1.hand, 7)
    }

    func testPlaceTileMovesToElephantPhase() {
        let game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        let slide = ElephantLogic.validSlides(board: game.board).first!
        let newGame = GameEngine.placeTile(slide: slide, game: game)
        XCTAssertEqual(newGame.phase, .moveElephant)
    }

    func testMoveElephantSwitchesTurn() {
        var game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        let slide = ElephantLogic.validSlides(board: game.board).first!
        game = GameEngine.placeTile(slide: slide, game: game)
        XCTAssertEqual(game.phase, .moveElephant)

        let elephantMoves = ElephantLogic.validMoves(from: game.board.elephantSpace)
        game = GameEngine.moveElephant(to: elephantMoves.first!, game: game)
        XCTAssertEqual(game.phase, .placeTile)
        XCTAssertEqual(game.currentPlayerId, PlayerState.botId)
    }

    func testMoveElephantStayInPlace() {
        var game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        let slide = ElephantLogic.validSlides(board: game.board).first!
        game = GameEngine.placeTile(slide: slide, game: game)
        let currentElephant = game.board.elephantSpace
        game = GameEngine.moveElephant(to: currentElephant, game: game)
        XCTAssertEqual(game.board.elephantSpace, currentElephant)
    }

    func testCannotPlaceTileDuringElephantPhase() {
        var game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        let slide = ElephantLogic.validSlides(board: game.board).first!
        game = GameEngine.placeTile(slide: slide, game: game)
        XCTAssertEqual(game.phase, .moveElephant)

        // Try to place another tile — should be rejected
        let slide2 = ElephantLogic.validSlides(board: game.board).first!
        let rejected = GameEngine.placeTile(slide: slide2, game: game)
        XCTAssertEqual(rejected.phase, .moveElephant) // unchanged
    }

    func testMovesAreRecorded() {
        var game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        XCTAssertTrue(game.moves.isEmpty)

        let slide = ElephantLogic.validSlides(board: game.board).first!
        game = GameEngine.placeTile(slide: slide, game: game)
        XCTAssertEqual(game.moves.count, 1)
        XCTAssertEqual(game.moves[0].type, .tile)

        let elephantMove = ElephantLogic.validMoves(from: game.board.elephantSpace).first!
        game = GameEngine.moveElephant(to: elephantMove, game: game)
        XCTAssertEqual(game.moves.count, 2)
        XCTAssertEqual(game.moves[1].type, .elephant)
    }

    func testPushedOffTileReturnsToHand() {
        var game = GameEngine.newBotGame(playerId: "p1", playerName: "Test")
        // Fill row 1 with alternating tiles: path [1, 2, 3, 4]
        game.board.spaces[1] = "p1"
        game.board.spaces[2] = PlayerState.botId
        game.board.spaces[3] = "p1"
        game.board.spaces[4] = PlayerState.botId
        game.board.elephantSpace = 6 // not in the way
        game.player2.hand = 6 // bot has 6 tiles in hand

        let slide = Slide(entrySpace: 1, direction: .right)
        let newGame = GameEngine.placeTile(slide: slide, game: game)
        // Bot's tile at space 4 was pushed off, should get +1 to hand
        XCTAssertEqual(newGame.player2.hand, 7) // 6 + 1
    }
}

final class RatingTests: XCTestCase {

    func testEqualRatingWin() {
        let newRating = Rating.calculateNewRating(playerRating: 1000, opponentRating: 1000, result: .win)
        XCTAssertEqual(newRating, 1016) // 1000 + 32 * (1.0 - 0.5) = 1016
    }

    func testEqualRatingLoss() {
        let newRating = Rating.calculateNewRating(playerRating: 1000, opponentRating: 1000, result: .loss)
        XCTAssertEqual(newRating, 984) // 1000 + 32 * (0.0 - 0.5) = 984
    }

    func testEqualRatingDraw() {
        let newRating = Rating.calculateNewRating(playerRating: 1000, opponentRating: 1000, result: .draw)
        XCTAssertEqual(newRating, 1000) // no change for equal ratings draw
    }

    func testUnderdogWin() {
        let newRating = Rating.calculateNewRating(playerRating: 800, opponentRating: 1200, result: .win)
        // Expected is very low, so gain is large
        XCTAssertGreaterThan(newRating, 824)
    }

    func testRatingClampedToMin() {
        let newRating = Rating.calculateNewRating(playerRating: 100, opponentRating: 100, result: .loss)
        XCTAssertGreaterThanOrEqual(newRating, 100)
    }

    func testRatingClampedToMax() {
        let newRating = Rating.calculateNewRating(playerRating: 3000, opponentRating: 3000, result: .win)
        XCTAssertLessThanOrEqual(newRating, 3000)
    }
}
