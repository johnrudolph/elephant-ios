import SwiftUI

struct GameScreenView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Top bar: mute toggle
                HStack {
                    Spacer()
                    Button {
                        AudioManager.shared.isMuted.toggle()
                    } label: {
                        Image(systemName: AudioManager.shared.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing)
                }

                // Opponent info
                PlayerInfoCard(
                    player: viewModel.player2,
                    isCurrentTurn: viewModel.currentPlayerId == viewModel.player2.id,
                    isPlayer1: false,
                    isVictor: viewModel.victorIds.contains(viewModel.player2.id),
                    victoryShape: viewModel.victoryShape
                )
                .padding(.horizontal)

                Spacer()

                // Status text (non-tutorial mode only)
                if !viewModel.isTutorialMode {
                    Text(viewModel.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .animation(.easeInOut, value: viewModel.statusText)
                }

                // Game board
                GameBoardView(viewModel: viewModel)

                // Turn timer
                if viewModel.showTimer {
                    TurnTimerView(
                        progress: viewModel.timerProgress,
                        isUrgent: viewModel.isTimerUrgent
                    )
                    .padding(.horizontal, 44)
                    .animation(.linear(duration: 0.1), value: viewModel.timerProgress)
                }

                Spacer()

                // Player info — highlight during tutorial victory shape step
                PlayerInfoCard(
                    player: viewModel.player1,
                    isCurrentTurn: viewModel.currentPlayerId == viewModel.player1.id,
                    isPlayer1: true,
                    isVictor: viewModel.victorIds.contains(viewModel.player1.id),
                    victoryShape: viewModel.victoryShape
                )
                .padding(.horizontal)
                .overlay {
                    if viewModel.tutorial?.currentStep == .showVictoryShape {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("PlayerOrange"), lineWidth: 3)
                            .padding(.horizontal)
                            .modifier(PulseModifier())
                    }
                }

                // Post-game overlay
                if viewModel.isComplete {
                    VStack(spacing: 12) {
                        Text(viewModel.victorIds.contains(viewModel.player1.id) ? "Victory!" : viewModel.victorIds.isEmpty ? "Draw" : "Defeat")
                            .font(.largeTitle.bold())
                            .foregroundStyle(
                                viewModel.victorIds.contains(viewModel.player1.id)
                                    ? Color("PlayerOrange")
                                    : .secondary
                            )

                        Button(action: { viewModel.startNewBotGame() }) {
                            Text("Play Again")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical)

            // Tutorial overlay (banner + buttons)
            TutorialOverlay(viewModel: viewModel)
        }
        .onAppear {
            if viewModel.isTutorialMode {
                // Tutorial handles its own flow
            } else if viewModel.isPlayerTurn {
                viewModel.startTimer()
            } else if viewModel.game.currentPlayer.isBot && !viewModel.isComplete {
                viewModel.executeBotTurn()
            }
        }
    }
}

#Preview("Game Screen") {
    GameScreenView(viewModel: GameViewModel(game: GameEngine.newBotGame(playerId: "player1", playerName: "You")))
}
