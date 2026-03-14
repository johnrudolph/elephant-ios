import SwiftUI
import SwiftData

@main
struct elephant_iosApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: PersistedGame.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GameViewModel?
    @State private var showTutorial = false

    var body: some View {
        Group {
            if let viewModel {
                GameScreenView(viewModel: viewModel)
                    .overlay {
                        if showTutorial {
                            TutorialOverlay {
                                showTutorial = false
                                UserPreferences.hasCompletedTutorial = true
                            }
                        }
                    }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadOrCreateGame()
        }
        .onChange(of: viewModel?.game) { _, newGame in
            if let game = newGame {
                GameStore.save(game, context: modelContext)
            }
        }
    }

    private func loadOrCreateGame() {
        let isFirstLaunch = UserPreferences.isFirstLaunch

        if let savedGame = GameStore.loadInProgressGame(context: modelContext) {
            viewModel = GameViewModel(game: savedGame)
        } else {
            let game = GameEngine.newBotGame(playerId: "player1", playerName: "You")
            viewModel = GameViewModel(game: game)
        }

        if isFirstLaunch {
            showTutorial = true
            UserPreferences.markLaunched()
        }
    }
}
