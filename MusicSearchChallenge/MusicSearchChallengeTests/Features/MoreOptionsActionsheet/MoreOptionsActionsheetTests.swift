//
//  MoreOptionsActionsheetTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import SnapshotTesting
import Testing
import SongPlayer
import SwiftUI
@testable import MusicSearchChallenge

@MainActor
struct MoreOptionsActionsheetTests {
    @Test(.snapshots(record: .missing))
    func moreOptionsActionsheet_matchesSnapshot() {
        assertSnapshot(
            of: MoreOptionsActionsheet(
                song: .stub(
                    artistName: "Dream Theater",
                    collectionName: "Six Degrees of Inner Turbulence",
                    trackName: "The Glass Prison"
                ),
                onViewAlbum: {}
            )
            .frame(width: 390, height: 200),
            as: .image(layout: .sizeThatFits)
        )
    }
}
