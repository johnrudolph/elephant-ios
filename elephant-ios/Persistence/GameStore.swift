import Foundation
import SwiftData

@Model
final class PersistedGame {
    @Attribute(.unique) var gameId: UUID
    var gameData: Data
    var isComplete: Bool
    var createdAt: Date
    var updatedAt: Date

    init(gameState: GameState) throws {
        self.gameId = gameState.id
        self.gameData = try JSONEncoder().encode(gameState)
        self.isComplete = gameState.isComplete
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func decode() throws -> GameState {
        try JSONDecoder().decode(GameState.self, from: gameData)
    }

    func update(from gameState: GameState) throws {
        self.gameData = try JSONEncoder().encode(gameState)
        self.isComplete = gameState.isComplete
        self.updatedAt = Date()
    }
}

enum GameStore {
    static func save(_ game: GameState, context: ModelContext) {
        do {
            let targetId = game.id
            let descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate<PersistedGame> { persisted in
                    persisted.gameId == targetId
                }
            )
            if let existing = try context.fetch(descriptor).first {
                try existing.update(from: game)
            } else {
                let persisted = try PersistedGame(gameState: game)
                context.insert(persisted)
            }
            try context.save()
        } catch {
            // Persistence is best-effort for bot games
        }
    }

    static func loadInProgressGame(context: ModelContext) -> GameState? {
        do {
            var descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate<PersistedGame> { persisted in
                    persisted.isComplete == false
                },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            guard let persisted = try context.fetch(descriptor).first else { return nil }
            return try persisted.decode()
        } catch {
            return nil
        }
    }

    static func delete(gameId: UUID, context: ModelContext) {
        do {
            let targetId = gameId
            let descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate<PersistedGame> { persisted in
                    persisted.gameId == targetId
                }
            )
            if let existing = try context.fetch(descriptor).first {
                context.delete(existing)
                try context.save()
            }
        } catch {
            // Best-effort
        }
    }
}
