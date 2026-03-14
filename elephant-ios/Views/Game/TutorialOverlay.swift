import SwiftUI

struct TutorialOverlay: View {
    let onDismiss: () -> Void

    @State private var currentStep = 0

    private let steps: [(title: String, description: String, icon: String)] = [
        (
            "Welcome to Elephant in the Room!",
            "A strategy game where you slide tiles onto a 4×4 board and try to form a shape.",
            "hand.wave"
        ),
        (
            "Slide Tiles",
            "Swipe on the board to push a tile in from the edge. Tiles slide along the row or column.",
            "arrow.right.square"
        ),
        (
            "Move the Elephant",
            "After placing a tile, tap a highlighted space to move the elephant. It blocks tile slides!",
            "pawprint"
        ),
        (
            "Form Your Shape",
            "Arrange 4 of your tiles into the target shape shown on your player card. First to do it wins!",
            "star"
        ),
    ]

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Tutorial card
            VStack(spacing: 24) {
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text(steps[currentStep].title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(steps[currentStep].description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)

                // Step indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                // Navigation
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation { currentStep -= 1 }
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation { currentStep += 1 }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                    } else {
                        Button("Let's Play!") {
                            onDismiss()
                        }
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: 280)
            }
            .padding(32)
        }
        .transition(.opacity)
    }
}

#Preview {
    TutorialOverlay { }
}
