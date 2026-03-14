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
    /// Save or update a game state.
    static func save(_ game: GameState, context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate { $0.gameId == game.id }
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

    /// Load the most recent in-progress game, if any.
    static func loadInProgressGame(context: ModelContext) -> GameState? {
        do {
            var descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate { !$0.isComplete },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            guard let persisted = try context.fetch(descriptor).first else { return nil }
            return try persisted.decode()
        } catch {
            return nil
        }
    }

    /// Delete a persisted game.
    static func delete(gameId: UUID, context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<PersistedGame>(
                predicate: #Predicate { $0.gameId == gameId }
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
