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
                artistName: "Angine de Poitrine",
                collectionName: "Vol.II"
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
            artistName: "Angine de Poitrine",
            collectionName: "Vol.II",
            artworkURL100: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/54/91/db/5491db35-84a9-b4e5-83cc-b52fdf678bb2/11115.jpg/100x100bb.jpg")
        )
        let viewModel = AlbumViewModel(song: song)
        viewModel.state = .success
        viewModel.songs = [
            .stub(trackID: 1,
                  artistName: "Angine de Poitrine",
                  collectionName: "Vol.II",
                  trackName: "Fabienk"),
            .stub(trackID: 2,
                  artistName: "Angine de Poitrine",
                  collectionName: "Vol.II",
                  trackName: "Mata Zyklek"),
            .stub(trackID: 3,
                  artistName: "Angine de Poitrine",
                  collectionName: "Vol.II",
                  trackName: "Sarniezz"),
            .stub(trackID: 4,
                  artistName: "Angine de Poitrine",
                  collectionName: "Vol.II",
                  trackName: "Utzp")
        ]

        assertSnapshot(
            of: NavigationStack {
                AlbumView(song: viewModel.song, viewModel: viewModel)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
