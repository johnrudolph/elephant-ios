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

            // Elephant with shake feedback
            ElephantView(cellSize: cellSize)
                .position(pointFor(viewModel.elephantSpace))
                .animation(.easeInOut(duration: 0.7), value: viewModel.elephantSpace)
                .modifier(ShakeModifier(shaking: viewModel.blockedFeedbackActive && viewModel.blockedPath.contains(viewModel.elephantSpace)))
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

            // Tutorial slide hint arrow
            if let hint = viewModel.tutorial?.currentStep.highlightHint,
               case .slideArrow(let space, let direction) = hint {
                slideHintArrow(space: space, direction: direction)
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
                    .modifier(ShakeModifier(shaking: viewModel.blockedFeedbackActive && viewModel.blockedPath.contains(space)))
                    .allowsHitTesting(false)
                }
            }
        }
    }

    // MARK: - Tutorial Hint Arrow

    private func slideHintArrow(space: Int, direction: Direction) -> some View {
        let arrowPoint = arrowPosition(space: space, direction: direction)
        let rotation: Angle = switch direction {
        case .down: .degrees(90)
        case .up: .degrees(-90)
        case .right: .degrees(0)
        case .left: .degrees(180)
        }

        return Image(systemName: "arrow.right.circle.fill")
            .font(.title)
            .foregroundStyle(Color("PlayerOrange"))
            .rotationEffect(rotation)
            .position(arrowPoint)
            .opacity(0.8)
            .modifier(PulseModifier())
    }

    private func arrowPosition(space: Int, direction: Direction) -> CGPoint {
        let center = pointFor(space)
        let offset: CGFloat = cellSize * 0.7
        switch direction {
        case .down: return CGPoint(x: center.x, y: center.y - offset)
        case .up: return CGPoint(x: center.x, y: center.y + offset)
        case .right: return CGPoint(x: center.x - offset, y: center.y)
        case .left: return CGPoint(x: center.x + offset, y: center.y)
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
        guard viewModel.isPlayerTurn else { return }
        // Allow swipes even in "try blocked" tutorial steps
        guard viewModel.isTilePhase || (viewModel.tutorial?.blockedSlideToTry != nil && viewModel.phase == .placeTile) else { return }

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

        viewModel.attemptSlide(slide: slide)
    }
}

// MARK: - Shake Animation

struct ShakeModifier: ViewModifier {
    let shaking: Bool

    func body(content: Content) -> some View {
        content
            .offset(x: shaking ? -4 : 0)
            .animation(
                shaking
                    ? .easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)
                    : .default,
                value: shaking
            )
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.15 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

#Preview("Game Board") {
    GameBoardView(viewModel: GameViewModel(game: GameEngine.newBotGame(playerId: "player1", playerName: "You")))
}
