//
//  ThumbnailTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import SnapshotTesting
import SwiftUI
import Testing
@testable import MusicSearchChallenge

@MainActor
struct ThumbnailTests {
    @Test(.snapshots(record: .missing))
    func thumbnail_placeholder_matchesSnapshot() {
        assertSnapshot(
            of: Thumbnail(
                url: nil,
                size: 100,
                cornerRadius: 18,
                iconSize: 44
            ),
            as: .image(layout: .sizeThatFits)
        )
    }
}
