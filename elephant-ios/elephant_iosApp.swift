import SwiftUI

@main
struct elephant_iosApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

enum AppScreen {
    case menu
    case game(GameViewModel)
}

struct AppRootView: View {
    @State private var currentScreen: AppScreen

    init() {
        if UserPreferences.isFirstLaunch {
            UserPreferences.markLaunched()
            let tutorial = TutorialManager()
            let game = TutorialManager.createTutorialGame(playerId: "player1", playerName: "You")
            let vm = GameViewModel(game: game, tutorial: tutorial)
            _currentScreen = State(initialValue: .game(vm))
        } else {
            _currentScreen = State(initialValue: .menu)
        }
    }

    var body: some View {
        switch currentScreen {
        case .menu:
            MainMenuView(
                onNewBotGame: {
                    let game = GameEngine.newBotGame(playerId: "player1", playerName: "You")
                    let vm = GameViewModel(game: game)
                    currentScreen = .game(vm)
                },
                onMultiplayer: {
                    // Not yet implemented
                },
                onTutorial: {
                    let tutorial = TutorialManager()
                    let game = TutorialManager.createTutorialGame(playerId: "player1", playerName: "You")
                    let vm = GameViewModel(game: game, tutorial: tutorial)
                    currentScreen = .game(vm)
                }
            )
        case .game(let viewModel):
            GameScreenView(viewModel: viewModel) {
                currentScreen = .menu
            }
        }
    }
}
