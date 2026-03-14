import SwiftUI

struct VictoryShapeIcon: View {
    let shape: VictoryShape
    let color: Color
    let size: CGFloat

    private var cellSize: CGFloat { size / 4 }
    private var gap: CGFloat { 1 }

    var body: some View {
        Canvas { context, canvasSize in
            let cells = shapeCells
            for cell in cells {
                let rect = CGRect(
                    x: CGFloat(cell.col) * cellSize + gap,
                    y: CGFloat(cell.row) * cellSize + gap,
                    width: cellSize - gap * 2,
                    height: cellSize - gap * 2
                )
                let path = Path(roundedRect: rect, cornerRadius: 2)
                context.fill(path, with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }

    private var shapeCells: [(row: Int, col: Int)] {
        switch shape {
        case .square:
            return [(0, 0), (0, 1), (1, 0), (1, 1)]
        case .line:
            return [(0, 0), (0, 1), (0, 2), (0, 3)]
        case .el:
            return [(0, 0), (1, 0), (2, 0), (2, 1)]
        case .zig:
            return [(0, 0), (0, 1), (1, 1), (1, 2)]
        case .pyramid:
            return [(0, 0), (0, 1), (0, 2), (1, 1)]
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach(VictoryShape.allCases, id: \.self) { shape in
            VStack {
                VictoryShapeIcon(shape: shape, color: .orange, size: 40)
                Text(shape.rawValue)
                    .font(.caption2)
            }
        }
    }
    .padding()
}
