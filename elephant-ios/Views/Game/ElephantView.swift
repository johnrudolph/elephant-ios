import SwiftUI

struct ElephantView: View {
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: cellSize * 0.7, height: cellSize * 0.7)
            Text("🐘")
                .font(.system(size: cellSize * 0.4))
        }
    }
}
