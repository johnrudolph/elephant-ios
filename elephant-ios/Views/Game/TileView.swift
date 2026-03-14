import SwiftUI

struct TileView: View {
    let playerId: String
    let isPlayer1: Bool
    let isWinning: Bool
    let cellSize: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isPlayer1 ? Color("PlayerOrange") : Color("PlayerTeal"))
            .frame(width: cellSize - 4, height: cellSize - 4)
            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            .opacity(isWinning ? 1.0 : 0.9)
            .overlay {
                if isWinning {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                }
            }
    }
}
