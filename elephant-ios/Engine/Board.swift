import Foundation

struct Board: Equatable, Codable {
    /// Maps space number (1-16) to player ID. Missing key = empty space.
    var spaces: [Int: String]
    var elephantSpace: Int

    static let size = 4
    static let spaceCount = 16

    static let empty = Board(
        spaces: [:],
        elephantSpace: 6
    )

    static func row(of space: Int) -> Int {
        (space - 1) / size
    }

    static func col(of space: Int) -> Int {
        (space - 1) % size
    }

    static func space(row: Int, col: Int) -> Int {
        row * size + col + 1
    }

    static func adjacentSpaces(of space: Int) -> [Int] {
        let r = row(of: space)
        let c = col(of: space)
        var result: [Int] = []
        if r > 0 { result.append(self.space(row: r - 1, col: c)) }
        if r < size - 1 { result.append(self.space(row: r + 1, col: c)) }
        if c > 0 { result.append(self.space(row: r, col: c - 1)) }
        if c < size - 1 { result.append(self.space(row: r, col: c + 1)) }
        return result
    }

    func owner(of space: Int) -> String? {
        spaces[space]
    }

    func isOccupied(_ space: Int) -> Bool {
        spaces[space] != nil
    }

    func isEmpty(_ space: Int) -> Bool {
        spaces[space] == nil
    }

    func spacesOwnedBy(_ playerId: String) -> [Int] {
        (1...Board.spaceCount).filter { spaces[$0] == playerId }
    }
}
