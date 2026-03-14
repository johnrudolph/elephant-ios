import SwiftUI

struct PlayerInfoCard: View {
    let player: PlayerState
    let isCurrentTurn: Bool
    let isPlayer1: Bool
    let isVictor: Bool
    let victoryShape: VictoryShape

    var body: some View {
        HStack(spacing: 12) {
            // Player color indicator
            Circle()
                .fill(isPlayer1 ? Color("PlayerOrange") : Color("PlayerTeal"))
                .frame(width: 12, height: 12)

            // Name
            Text(player.name)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            // Hand count
            HStack(spacing: 4) {
                Image(systemName: "square.stack")
                    .font(.caption)
                Text("\(player.hand)")
                    .font(.subheadline.monospacedDigit())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill((isPlayer1 ? Color("PlayerOrange") : Color("PlayerTeal")).opacity(0.2))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(isCurrentTurn ? 0.15 : 0.05), radius: isCurrentTurn ? 4 : 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isVictor
                        ? (isPlayer1 ? Color("PlayerOrange") : Color("PlayerTeal"))
                        : Color.clear,
                    lineWidth: 2
                )
        )
        .opacity(isCurrentTurn || isVictor ? 1.0 : 0.6)
    }
}
