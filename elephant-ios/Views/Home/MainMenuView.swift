import SwiftUI

struct MainMenuView: View {
    let onNewBotGame: () -> Void
    let onMultiplayer: () -> Void
    let onTutorial: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Text("Elephant")
                    .font(.largeTitle.bold())
                Text("in the Room")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Menu buttons
            VStack(spacing: 16) {
                Button(action: onNewBotGame) {
                    Label("Play vs Bot", systemImage: "cpu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onMultiplayer) {
                    Label("Challenge a Friend", systemImage: "person.2")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .disabled(true) // Not yet implemented
                .opacity(0.5)

                Button(action: onTutorial) {
                    Label("How to Play", systemImage: "questionmark.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 40)

            // Settings row
            HStack {
                Toggle(isOn: Binding(
                    get: { AudioManager.shared.isMuted },
                    set: { AudioManager.shared.isMuted = $0 }
                )) {
                    Label("Mute", systemImage: "speaker.slash")
                }
                .toggleStyle(.switch)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview("Main Menu") {
    MainMenuView(
        onNewBotGame: {},
        onMultiplayer: {},
        onTutorial: {}
    )
}
