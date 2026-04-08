//
//  SplashViewTests.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import SnapshotTesting
import Testing
@testable import MusicSearchChallenge

@MainActor
struct SplashViewTests {
    @Test(.snapshots(record: .missing))
    func splashView_matchesSnapshot() {
        assertSnapshot(
            of: SplashView(),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
