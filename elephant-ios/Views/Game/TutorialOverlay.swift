import SwiftUI

struct TutorialOverlay: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        if let tutorial = viewModel.tutorial, !tutorial.isComplete {
            VStack {
                // Tutorial banner at top
                tutorialBanner(step: tutorial.currentStep)

                Spacer()

                // Info steps: tap to continue
                if tutorial.currentStep == .showVictoryShape || tutorial.currentStep == .explainTiles {
                    Button {
                        viewModel.advanceTutorialInfo()
                    } label: {
                        Text("Got it!")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color("PlayerOrange"))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 24)
                }
            }
            .allowsHitTesting(
                tutorial.currentStep == .showVictoryShape ||
                tutorial.currentStep == .explainTiles
            )
        }
    }

    @ViewBuilder
    private func tutorialBanner(step: TutorialStep) -> some View {
        let text = viewModel.statusText
        if !text.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: iconForStep(step))
                    .font(.title3)
                Text(text)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: step)
        }
    }

    private func iconForStep(_ step: TutorialStep) -> String {
        switch step {
        case .slideDown2, .slideDown1, .tryBlockedRight5, .tryBlockedDown2:
            return "arrow.down.square"
        case .moveElephantTo5, .moveElephantTo6:
            return "pawprint"
        case .botPlays16, .botPushes:
            return "person.fill"
        case .showVictoryShape:
            return "star"
        case .explainTiles:
            return "square.stack"
        case .freePlay:
            return "play"
        }
    }
}
