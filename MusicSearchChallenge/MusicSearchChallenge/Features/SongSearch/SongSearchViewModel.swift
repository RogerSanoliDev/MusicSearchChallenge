//
//  SongSearchViewModel.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
import Observation

@Observable
final class SongSearchViewModel {
    enum State {
        case idle
        case recent
        case loading
        case success
        case error
        case empty
    }
    
    var searchText = ""
    var state: State = .idle
    
    private let searchService: SearchServiceProtocol

    init(searchService: SearchServiceProtocol = SearchService()) {
        self.searchService = searchService
    }
}
