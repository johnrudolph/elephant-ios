import SwiftUI

@main
struct elephant_iosApp: App {
    @State private var viewModel = GameViewModel(
        game: GameEngine.newBotGame(playerId: "player1", playerName: "You")
    )

    var body: some Scene {
        WindowGroup {
            GameScreenView(viewModel: viewModel)
        }
    }
}
