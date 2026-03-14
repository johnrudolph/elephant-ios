import Foundation

enum VictoryShape: String, Codable, CaseIterable {
    case square, line, el, zig, pyramid

    /// All valid 4-space configurations that form this victory shape.
    var configurations: [[Int]] {
        switch self {
        case .square:
            return VictoryShape.squareConfigs
        case .line:
            return VictoryShape.lineConfigs
        case .el:
            return VictoryShape.elConfigs
        case .zig:
            return VictoryShape.zigConfigs
        case .pyramid:
            return VictoryShape.pyramidConfigs
        }
    }

    /// Shapes available for bot games (zig and pyramid excluded).
    static let botShapes: [VictoryShape] = [.square, .line, .el]

    // MARK: - Square (2x2 block) — 9 configurations

    private static let squareConfigs: [[Int]] = {
        var configs: [[Int]] = []
        for row in 0..<3 {
            for col in 0..<3 {
                let tl = Board.space(row: row, col: col)
                let tr = Board.space(row: row, col: col + 1)
                let bl = Board.space(row: row + 1, col: col)
                let br = Board.space(row: row + 1, col: col + 1)
                configs.append([tl, tr, bl, br])
            }
        }
        return configs
    }()

    // MARK: - Line (4 in a row) — 8 configurations

    private static let lineConfigs: [[Int]] = {
        var configs: [[Int]] = []
        // Horizontal lines
        for row in 0..<4 {
            configs.append((0..<4).map { Board.space(row: row, col: $0) })
        }
        // Vertical lines
        for col in 0..<4 {
            configs.append((0..<4).map { Board.space(row: $0, col: col) })
        }
        return configs
    }()

    // MARK: - El (L-shape) — 48 configurations (8 orientations)

    private static let elConfigs: [[Int]] = {
        // Relative offsets for all 8 orientations of the L-tetromino
        let orientations: [[(Int, Int)]] = [
            // ┌──
            // │
            // │
            [(0,0), (0,1), (0,2), (1,0)],
            // │
            // │
            // └──
            [(0,0), (1,0), (2,0), (2,1)],
            //    │
            //    │
            // ──┘
            [(0,2), (1,2), (2,1), (2,2)],
            // ──┐
            //   │
            //   │
            [(0,0), (0,1), (1,1), (2,1)],
            // ──┐
            // │
            [(0,0), (0,1), (0,2), (1,2)],
            //   │
            //   │
            // ──┘
            [(0,1), (1,1), (2,0), (2,1)],
            // │
            // └──
            [(0,0), (1,0), (1,1), (1,2)],
            // ──┐
            //   │
            [(0,0), (0,1), (1,0), (2,0)],
        ]
        return generateConfigs(orientations: orientations)
    }()

    // MARK: - Zig (S/Z-shape) — 24 configurations (4 orientations)

    private static let zigConfigs: [[Int]] = {
        let orientations: [[(Int, Int)]] = [
            // S horizontal
            [(0,1), (0,2), (1,0), (1,1)],
            // Z horizontal
            [(0,0), (0,1), (1,1), (1,2)],
            // S vertical
            [(0,0), (1,0), (1,1), (2,1)],
            // Z vertical
            [(0,1), (1,0), (1,1), (2,0)],
        ]
        return generateConfigs(orientations: orientations)
    }()

    // MARK: - Pyramid (T-shape) — 24 configurations (4 orientations)

    private static let pyramidConfigs: [[Int]] = {
        let orientations: [[(Int, Int)]] = [
            // T up
            [(0,0), (0,1), (0,2), (1,1)],
            // T right
            [(0,0), (1,0), (1,1), (2,0)],
            // T down
            [(0,1), (1,0), (1,1), (1,2)],
            // T left
            [(0,1), (1,0), (1,1), (2,1)],
        ]
        return generateConfigs(orientations: orientations)
    }()

    // MARK: - Helpers

    private static func generateConfigs(orientations: [[(Int, Int)]]) -> [[Int]] {
        var configs: [[Int]] = []
        for offsets in orientations {
            let maxRow = offsets.map(\.0).max()!
            let maxCol = offsets.map(\.1).max()!
            for startRow in 0..<(4 - maxRow) {
                for startCol in 0..<(4 - maxCol) {
                    let spaces = offsets.map { Board.space(row: startRow + $0.0, col: startCol + $0.1) }
                    configs.append(spaces)
                }
            }
        }
        return configs
    }
}
