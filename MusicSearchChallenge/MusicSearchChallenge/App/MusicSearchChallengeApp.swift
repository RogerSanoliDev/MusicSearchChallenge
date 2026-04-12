//
//  MusicSearchChallengeApp.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 06/04/26.
//

import SwiftUI
import SwiftData

@main
struct MusicSearchChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(LocalStorageRepositoryFactory.sharedModelContainer)
    }
}
