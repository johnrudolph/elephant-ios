import Foundation

enum MoveType: String, Codable {
    case tile, elephant
}

struct MoveRecord: Codable, Equatable {
    let playerId: String
    let type: MoveType
    let boardBefore: Board
    let boardAfter: Board
    let slide: Slide?
}
