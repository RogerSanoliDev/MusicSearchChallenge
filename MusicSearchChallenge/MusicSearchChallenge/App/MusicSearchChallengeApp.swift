//
//  MusicSearchChallengeApp.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 06/04/26.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct MusicSearchChallengeApp: App {
    init() {
        do {
            try Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        } catch {
            assertionFailure("Failed to configure TipKit: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(LocalStorageRepositoryFactory.sharedModelContainer)
    }
}
