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
    
    var searchText = "" {
        didSet {
            scheduleSearch()
        }
    }
    var state: State = .idle
    var songs: [Song] = []
    
    @ObservationIgnored
    private let searchService: SearchServiceProtocol
    @ObservationIgnored
    private let searchDebounceDuration: Duration
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    init(
        searchService: SearchServiceProtocol = SearchService(),
        searchDebounceDuration: Duration = .milliseconds(300)
    ) {
        self.searchService = searchService
        self.searchDebounceDuration = searchDebounceDuration
    }

    deinit {
        searchTask?.cancel()
    }

    private func scheduleSearch() {
        searchTask?.cancel()

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            state = .idle
            songs = []
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: self.searchDebounceDuration)
                guard !Task.isCancelled else { return }

                await self.performSearch(for: trimmedSearchText)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    private func performSearch(for term: String) async {
        state = .loading

        do {
            let foundSongs = try await searchService.search(term: term, limit: 10, offset: 0)

            // Prevents stale async results and canceled searches.
            guard !Task.isCancelled else { return }
            guard term == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            songs = foundSongs
            state = foundSongs.isEmpty ? .empty : .success
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            guard term == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            songs = []
            state = .error
        }
    }
}
