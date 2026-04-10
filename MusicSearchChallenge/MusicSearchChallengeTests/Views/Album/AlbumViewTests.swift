//
//  AlbumViewTests.swift
//  MusicSearchChallenge
//
//  Created by Codex on 10/04/26.
//

import SnapshotTesting
import Testing
import SongPlayer
import SwiftUI
@testable import MusicSearchChallenge

@MainActor
struct AlbumViewTests {
    @Test(.snapshots(record: .missing))
    func albumView_loading_matchesSnapshot() {
        let viewModel = AlbumViewModel(
            song: .stub(
                artistName: "Daft Punk",
                collectionName: "Discovery",
                artworkURL100: nil
            )
        )
        viewModel.state = .loading

        assertSnapshot(
            of: NavigationStack {
                AlbumView(song: viewModel.song, viewModel: viewModel)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func albumView_success_matchesSnapshot() {
        let song = Song.stub(
            collectionID: 42,
            artistName: "Daft Punk",
            collectionName: "Discovery",
            artworkURL100: nil
        )
        let viewModel = AlbumViewModel(song: song)
        viewModel.state = .success
        viewModel.songs = [
            .stub(collectionID: 42, trackID: 1, artistName: "Daft Punk", collectionName: "Discovery", trackName: "One More Time"),
            .stub(collectionID: 42, trackID: 2, artistName: "Daft Punk", collectionName: "Discovery", trackName: "Aerodynamic"),
            .stub(collectionID: 42, trackID: 3, artistName: "Daft Punk", collectionName: "Discovery", trackName: "Digital Love"),
            .stub(collectionID: 42, trackID: 4, artistName: "Daft Punk", collectionName: "Discovery", trackName: "Harder, Better, Faster, Stronger"),
        ]

        assertSnapshot(
            of: NavigationStack {
                AlbumView(song: viewModel.song, viewModel: viewModel)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
