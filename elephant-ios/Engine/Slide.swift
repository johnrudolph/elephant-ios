import Foundation

enum Direction: String, Codable, CaseIterable {
    case up, down, left, right
}

struct Slide: Codable, Equatable, Hashable {
    let entrySpace: Int
    let direction: Direction

    /// Returns the 4-space path for this slide (entry → exit).
    /// The new tile enters at index 0; a tile pushed off exits from index 3.
    var path: [Int] {
        Slide.slidingPositions[self] ?? []
    }

    /// All 16 valid slide configurations.
    /// Each maps an entry space + direction to the 4-space path.
    static let slidingPositions: [Slide: [Int]] = {
        var positions: [Slide: [Int]] = [:]

        // Down (from top edge): entry spaces 1-4
        for col in 0..<4 {
            let entry = col + 1
            let slide = Slide(entrySpace: entry, direction: .down)
            positions[slide] = (0..<4).map { row in Board.space(row: row, col: col) }
        }

        // Up (from bottom edge): entry spaces 13-16
        for col in 0..<4 {
            let entry = 13 + col
            let slide = Slide(entrySpace: entry, direction: .up)
            positions[slide] = (0..<4).reversed().map { row in Board.space(row: row, col: col) }
        }

        // Right (from left edge): entry spaces 1, 5, 9, 13
        for row in 0..<4 {
            let entry = row * 4 + 1
            let slide = Slide(entrySpace: entry, direction: .right)
            positions[slide] = (0..<4).map { col in Board.space(row: row, col: col) }
        }

        // Left (from right edge): entry spaces 4, 8, 12, 16
        for row in 0..<4 {
            let entry = row * 4 + 4
            let slide = Slide(entrySpace: entry, direction: .left)
            positions[slide] = (0..<4).reversed().map { col in Board.space(row: row, col: col) }
        }

        return positions
    }()

    /// All 16 valid slides.
    static let allSlides: [Slide] = Array(slidingPositions.keys)
}
