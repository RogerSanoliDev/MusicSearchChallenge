//
//  SongSearchViewTests.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SnapshotTesting
import Testing
import SongPlayer
import SwiftUI
@testable import MusicSearchChallenge

@MainActor
struct SongSearchViewTests {
    @Test(.snapshots(record: .missing))
    func songSearchView_idle_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .idle

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func songSearchView_error_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .error

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func songSearchView_empty_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.searchText = "Bohemian Rhapsody"
        viewModel.state = .empty

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func songSearchView_loading_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .loading

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func songSearchView_recentPlayed_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .recentPlayed
        viewModel.recentPlayedSongs = [
            .stub(trackID: 1, artistName: "Dream Theater", collectionName: "Images and Words", trackName: "Pull Me Under"),
            .stub(trackID: 2, artistName: "Dream Theater", collectionName: "Awake", trackName: "6:00"),
            .stub(trackID: 3, artistName: "Dream Theater", collectionName: "Octavarium", trackName: "Panic Attack"),
        ]

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @Test(.snapshots(record: .missing))
    func songSearchView_success_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .success
        viewModel.songs = [
            .stub(trackID: 1, artistName: "Dream Theater", collectionName: "Images and Words", trackName: "Pull Me Under"),
            .stub(trackID: 2, artistName: "Dream Theater", collectionName: "Awake", trackName: "6:00"),
            .stub(trackID: 3, artistName: "Dream Theater", collectionName: "Metropolis Pt. 2: Scenes from a Memory", trackName: "The Spirit Carries On"),
            .stub(trackID: 4, artistName: "Dream Theater", collectionName: "Train of Thought", trackName: "As I Am"),
            .stub(trackID: 5, artistName: "Dream Theater", collectionName: "Octavarium", trackName: "Panic Attack"),
        ]

        assertSnapshot(
            of: NavigationStack {
                SongSearchView(viewModel: viewModel, showsTips: false)
            },
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
