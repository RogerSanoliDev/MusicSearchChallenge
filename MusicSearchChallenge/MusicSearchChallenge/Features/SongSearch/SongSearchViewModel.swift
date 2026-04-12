//
//  SongSearchViewModel.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
import Observation
import SongPlayer

@MainActor
@Observable
final class SongSearchViewModel {
    enum State {
        case idle
        case recentPlayed
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
    var recentPlayedSongs: [Song] = []
    var isLoadingNextPage = false
    var hasMorePages = false
    
    @ObservationIgnored
    private let searchService: SearchServiceProtocol
    @ObservationIgnored
    private let searchDebounceDuration: Duration
    @ObservationIgnored
    private let searchLimit: Int
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?
    @ObservationIgnored
    private var paginationTask: Task<Void, Never>?
    @ObservationIgnored
    private var currentOffset = 0

    init(
        searchService: SearchServiceProtocol = SearchService(),
        searchDebounceDuration: Duration = .milliseconds(300),
        searchLimit: Int = 10
    ) {
        self.searchService = searchService
        self.searchDebounceDuration = searchDebounceDuration
        self.searchLimit = searchLimit

        Task { [weak self] in
            await self?.loadRecentPlayed()
        }
    }

    deinit {
        searchTask?.cancel()
        paginationTask?.cancel()
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        paginationTask?.cancel()

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            restoreInitialState()
            songs = []
            isLoadingNextPage = false
            hasMorePages = false
            currentOffset = 0
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Task.sleep(for: self.searchDebounceDuration)
                guard !Task.isCancelled else { return }

                self.resetPagination()
                await self.searchPage(for: trimmedSearchText, offset: 0)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    private func resetPagination() {
        songs = []
        currentOffset = 0
        isLoadingNextPage = false
        hasMorePages = true
    }

    func reloadSearch() async {
        searchTask?.cancel()
        paginationTask?.cancel()

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearchText.isEmpty else {
            restoreInitialState()
            songs = []
            isLoadingNextPage = false
            hasMorePages = false
            currentOffset = 0
            return
        }

        resetPagination()
        await searchPage(for: trimmedSearchText, offset: 0)
    }

    private func searchPage(for term: String, offset: Int) async {
        if songs.isEmpty {
            state = .loading
        }

        do {
            let foundSongs = try await searchService.search(term: term, limit: searchLimit, offset: offset)

            // Prevents stale async results and canceled searches.
            guard !Task.isCancelled else { return }
            guard term == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            let songsCountBeforeAppend = songs.count
            let existingTrackIDs = Set(songs.map(\.trackID))
            let newSongs = foundSongs.filter { !existingTrackIDs.contains($0.trackID) }

            songs.append(contentsOf: newSongs)
            currentOffset = offset
            isLoadingNextPage = false
            hasMorePages = songs.count != songsCountBeforeAppend
            state = songs.isEmpty ? .empty : .success
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            guard term == searchText.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

            isLoadingNextPage = false
            hasMorePages = false

            if songs.isEmpty {
                state = .error
            }
        }
    }

    func loadNextPageIfNeeded() {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            state == .success,
            !trimmedSearchText.isEmpty,
            hasMorePages,
            !isLoadingNextPage
        else { return }

        let nextOffset = currentOffset + searchLimit
        isLoadingNextPage = true

        paginationTask = Task { [weak self] in
            guard let self else { return }
            await self.searchPage(for: trimmedSearchText, offset: nextOffset)
        }
    }

    func didSelectSong(at index: Int) -> Song? {
        let availableSongs: [Song]

        switch state {
        case .recentPlayed:
            availableSongs = recentPlayedSongs
        case .success:
            availableSongs = songs
        default:
            return nil
        }

        guard availableSongs.indices.contains(index) else { return nil }
        return availableSongs[index]
    }

    private func loadRecentPlayed() async {
        do {
            let recentPlayedSongs = try await searchService.fetchRecentPlayed()
            guard !Task.isCancelled else { return }

            self.recentPlayedSongs = recentPlayedSongs

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                restoreInitialState()
            }
        } catch {
            guard !Task.isCancelled else { return }
            recentPlayedSongs = []

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                restoreInitialState()
            }
        }
    }

    private func restoreInitialState() {
        state = recentPlayedSongs.isEmpty ? .idle : .recentPlayed
        if state == .recentPlayed {
            Task { [weak self] in
                await self?.loadRecentPlayed()
            }
        }
    }
}
