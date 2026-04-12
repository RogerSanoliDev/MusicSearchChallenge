//
//  SongCellTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import SnapshotTesting
import Testing
import SwiftUI
@testable import MusicSearchChallenge

@MainActor
struct SongCellTests {
    @Test(.snapshots(record: .missing))
    func songCell_withoutMoreOptions_matchesSnapshot() {
        assertSnapshot(
            of: SongCell(
                song: .stub(
                    artistName: "Tool",
                    collectionName: "Lateralus",
                    trackName: "Lateralus",
                    artworkURL60: nil
                ),
                showsMoreOptionsButton: false
            )
            .padding()
            .frame(width: 390),
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test(.snapshots(record: .missing))
    func songCell_withMoreOptions_matchesSnapshot() {
        assertSnapshot(
            of: SongCell(
                song: .stub(
                    artistName: "Tool",
                    collectionName: "Lateralus",
                    trackName: "Lateralus",
                    artworkURL60: nil
                ),
                showsMoreOptionsButton: true,
                onMoreOptionsTap: {}
            )
            .padding()
            .frame(width: 390),
            as: .image(layout: .sizeThatFits)
        )
    }
}
