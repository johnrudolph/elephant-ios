import SwiftUI

struct GameScreenView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Opponent info (top)
            PlayerInfoCard(
                player: viewModel.player2,
                isCurrentTurn: viewModel.currentPlayerId == viewModel.player2.id,
                isPlayer1: false,
                isVictor: viewModel.victorIds.contains(viewModel.player2.id),
                victoryShape: viewModel.victoryShape
            )
            .padding(.horizontal)

            Spacer()

            // Status text
            Text(viewModel.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Game board
            GameBoardView(viewModel: viewModel)

            Spacer()

            // Player info (bottom)
            PlayerInfoCard(
                player: viewModel.player1,
                isCurrentTurn: viewModel.currentPlayerId == viewModel.player1.id,
                isPlayer1: true,
                isVictor: viewModel.victorIds.contains(viewModel.player1.id),
                victoryShape: viewModel.victoryShape
            )
            .padding(.horizontal)

            // Post-game actions
            if viewModel.isComplete {
                Button(action: { viewModel.startNewBotGame() }) {
                    Text("Play Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    let game = GameEngine.newBotGame(playerId: "player1", playerName: "You")
    GameScreenView(viewModel: GameViewModel(game: game))
}
