//
//  InfoViewTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import SnapshotTesting
import Testing
import SwiftUI
@testable import MusicSearchChallenge

@MainActor
struct InfoViewTests {
    @Test(.snapshots(record: .missing))
    func infoView_matchesSnapshot() {
        assertSnapshot(
            of: InfoView(
                systemImageName: "magnifyingglass",
                message: "Start searching songs"
            )
            .frame(width: 390, height: 300),
            as: .image(layout: .sizeThatFits)
        )
    }
}
