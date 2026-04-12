//
//  LocalStorageRepositoryFactory.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import SwiftData

enum LocalStorageRepositoryFactory {
    @MainActor
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StoredSong.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @MainActor
    static func makeDefaultRepository() -> LocalStorageRepository {
        LocalStorageRepository(modelContext: sharedModelContainer.mainContext)
    }
}
