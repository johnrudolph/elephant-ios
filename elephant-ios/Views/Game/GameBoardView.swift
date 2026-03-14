import SwiftUI

struct GameBoardView: View {
    @Bindable var viewModel: GameViewModel

    let cellSize: CGFloat = 72
    let spacing: CGFloat = 4

    private var boardSize: CGFloat {
        cellSize * 4 + spacing * 3
    }

    var body: some View {
        ZStack {
            gridBackground
            tilesLayer

            ElephantView(cellSize: cellSize)
                .position(pointFor(viewModel.elephantSpace))
                .animation(.easeInOut(duration: 0.7), value: viewModel.elephantSpace)
                .allowsHitTesting(false)

            if viewModel.isElephantPhase {
                ElephantMoveOverlay(
                    validMoves: viewModel.validElephantMoves,
                    cellSize: cellSize,
                    spacing: spacing
                ) { space in
                    viewModel.moveElephant(to: space)
                }
            }
        }
        .frame(width: boardSize, height: boardSize)
        .padding(44)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    handleDrag(value)
                }
        )
    }

    // MARK: - Grid

    private var gridBackground: some View {
        VStack(spacing: spacing) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("BoardCell"))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }

    // MARK: - Tiles

    private var tilesLayer: some View {
        let board = viewModel.board
        return ZStack {
            ForEach(1...16, id: \.self) { space in
                if let owner = board.spaces[space] {
                    TileView(
                        playerId: owner,
                        isPlayer1: owner == viewModel.player1.id,
                        isWinning: viewModel.winningSpaces.contains(space),
                        cellSize: cellSize
                    )
                    .position(pointFor(space))
                    .allowsHitTesting(false)
                }
            }
        }
    }

    private func pointFor(_ space: Int) -> CGPoint {
        let col = CGFloat(Board.col(of: space))
        let row = CGFloat(Board.row(of: space))
        let x = col * (cellSize + spacing) + cellSize / 2
        let y = row * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }

    // MARK: - Slide Gesture

    private func handleDrag(_ value: DragGesture.Value) {
        guard viewModel.isPlayerTurn, viewModel.isTilePhase else { return }

        let start = value.startLocation
        let translation = value.translation

        let horizontal = abs(translation.width) > abs(translation.height)
        let direction: Direction
        if horizontal {
            direction = translation.width > 0 ? .right : .left
        } else {
            direction = translation.height > 0 ? .down : .up
        }

        let relX = start.x - 44
        let relY = start.y - 44
        let col = min(3, max(0, Int(relX / (cellSize + spacing))))
        let row = min(3, max(0, Int(relY / (cellSize + spacing))))

        let slide: Slide
        switch direction {
        case .right:
            slide = Slide(entrySpace: Board.space(row: row, col: 0), direction: .right)
        case .left:
            slide = Slide(entrySpace: Board.space(row: row, col: 3), direction: .left)
        case .down:
            slide = Slide(entrySpace: Board.space(row: 0, col: col), direction: .down)
        case .up:
            slide = Slide(entrySpace: Board.space(row: 3, col: col), direction: .up)
        }

        if viewModel.validSlides.contains(slide) {
            viewModel.placeTile(slide: slide)
        }
    }
}

#Preview("Game Board") {
    GameBoardView(viewModel: GameViewModel(game: GameEngine.newBotGame(playerId: "player1", playerName: "You")))
}
