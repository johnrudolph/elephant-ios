import Foundation

struct PlayerState: Codable, Equatable {
    let id: String
    let name: String
    var hand: Int
    let isBot: Bool
    var wantsRematch: Bool
    var rating: Int

    static let startingHand = 8
    static let botId = "bot@bot.bot"

    static func newPlayer(id: String, name: String, isBot: Bool = false, rating: Int = 1000) -> PlayerState {
        PlayerState(
            id: id,
            name: name,
            hand: startingHand,
            isBot: isBot,
            wantsRematch: false,
            rating: rating
        )
    }

    static func bot() -> PlayerState {
        newPlayer(id: botId, name: "Bot", isBot: true)
    }
}
