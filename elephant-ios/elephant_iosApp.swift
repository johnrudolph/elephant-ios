import SwiftUI

@main
struct elephant_iosApp: App {
    @State private var viewModel: GameViewModel = {
        let isFirstLaunch = UserPreferences.isFirstLaunch
        if isFirstLaunch {
            UserPreferences.markLaunched()
            let tutorial = TutorialManager()
            let game = TutorialManager.createTutorialGame(playerId: "player1", playerName: "You")
            return GameViewModel(game: game, tutorial: tutorial)
        } else {
            return GameViewModel(game: GameEngine.newBotGame(playerId: "player1", playerName: "You"))
        }
    }()

    var body: some Scene {
        WindowGroup {
            GameScreenView(viewModel: viewModel)
        }
    }
}
