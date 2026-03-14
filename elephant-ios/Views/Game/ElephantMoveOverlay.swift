import SwiftUI

struct ElephantMoveOverlay: View {
    let validMoves: [Int]
    let cellSize: CGFloat
    let spacing: CGFloat
    let onSelect: (Int) -> Void

    var body: some View {
        ForEach(validMoves, id: \.self) { space in
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
                .position(pointForSpace(space))
                .onTapGesture {
                    onSelect(space)
                }
        }
    }

    private func pointForSpace(_ space: Int) -> CGPoint {
        let col = CGFloat(Board.col(of: space))
        let row = CGFloat(Board.row(of: space))
        let x = col * (cellSize + spacing) + cellSize / 2
        let y = row * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }
}
