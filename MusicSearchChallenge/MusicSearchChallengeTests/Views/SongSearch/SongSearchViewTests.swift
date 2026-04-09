//
//  SongSearchViewTests.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
import SnapshotTesting
import Testing
@testable import MusicSearchChallenge

@MainActor
struct SongSearchViewTests {
    @Test(.snapshots(record: .missing))
    func songSearchView_idle_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .idle
        
        assertSnapshot(
            of: SongSearchView(viewModel: viewModel),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
    
    @Test(.snapshots(record: .missing))
    func songSearchView_error_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.state = .error
        
        assertSnapshot(
            of: SongSearchView(viewModel: viewModel),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
    
    @Test(.snapshots(record: .missing))
    func songSearchView_empty_matchesSnapshot() {
        let viewModel = SongSearchViewModel()
        viewModel.searchText = "Bohemian Rhapsody"
        viewModel.state = .empty
        
        assertSnapshot(
            of: SongSearchView(viewModel: viewModel),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
