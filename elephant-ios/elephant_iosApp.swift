import SwiftUI

@main
struct elephant_iosApp: App {
    @State private var viewModel = GameViewModel(
        game: GameEngine.newBotGame(playerId: "player1", playerName: "You")
    )
    @State private var showTutorial = UserPreferences.isFirstLaunch

    var body: some Scene {
        WindowGroup {
            GameScreenView(viewModel: viewModel)
                .overlay {
                    if showTutorial {
                        TutorialOverlay {
                            showTutorial = false
                            UserPreferences.hasCompletedTutorial = true
                            UserPreferences.markLaunched()
                        }
                    }
                }
        }
    }
}
