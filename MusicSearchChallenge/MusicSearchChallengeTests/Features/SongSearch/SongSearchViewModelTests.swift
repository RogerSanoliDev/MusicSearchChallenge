//
//  SongSearchViewModelTests.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
import Testing
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
struct SongSearchViewModelTests {
    @Test
    func searchText_performsSearchAfterDebounce_andUpdatesSuccessState() async throws {
        let mock = SearchServiceMock()
        await mock.setSearchHandler { term, limit, offset in
            #expect(term == "queen")
            #expect(limit == 10)
            #expect(offset == 0)

            return [.stub(trackID: 1, artistName: "Queen", trackName: "Bohemian Rhapsody")]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .milliseconds(50)
        )

        sut.searchText = "queen"

        try await Task.sleep(for: .milliseconds(10))
        #expect(await mock.searchCalls.isEmpty)

        await assertEventually {
            await mock.searchCalls.count == 1
                && sut.state == .success
                && sut.songs.count == 1
                && sut.songs.first?.trackName == "Bohemian Rhapsody"
        }
    }

    @Test
    func searchText_withEmptyResults_setsEmptyState() async throws {
        let mock = SearchServiceMock()
        await mock.setSearchHandler { _, _, _ in [] }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "unknown"

        await assertEventually {
            sut.state == .empty && sut.songs.isEmpty
        }
    }

    @Test
    func searchText_whenServiceFails_setsErrorState() async throws {
        enum SearchError: Error {
            case failed
        }

        let mock = SearchServiceMock()
        await mock.setSearchHandler { _, _, _ in
            throw SearchError.failed
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "queen"

        await assertEventually {
            sut.state == .error && sut.songs.isEmpty
        }
    }

    @Test
    func searchText_whenChangedDuringInFlightRequest_cancelsPreviousTask() async throws {
        let mock = SearchServiceMock()
        await mock.setSearchHandler { term, _, _ in
            if term == "beatles" {
                try await Task.sleep(for: .seconds(2))
                return [.stub(trackID: 1, artistName: "The Beatles", trackName: "Something")]
            }

            return [.stub(trackID: 2, artistName: "Queen", trackName: "Killer Queen")]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "beatles"
        await assertEventually {
            await mock.searchCalls.count == 1
        }

        sut.searchText = "queen"

        await assertEventually {
            let calls = await mock.searchCalls
            return calls.count == 2
                && calls.map(\.term) == ["beatles", "queen"]
                && sut.state == .success
                && sut.songs.first?.trackName == "Killer Queen"
        }
    }

    @Test
    func searchText_whenCleared_resetsToIdleWithoutSearching() async throws {
        let mock = SearchServiceMock()
        await mock.setSearchHandler { _, _, _ in
            [.stub(trackID: 1, artistName: "Artist", trackName: "Song")]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .milliseconds(50)
        )
        sut.state = .success
        sut.songs = [.stub(trackID: 1, artistName: "Artist", trackName: "Song")]

        sut.searchText = "   "

        await assertEventually {
            await mock.searchCalls.isEmpty
                && sut.state == .idle
                && sut.songs.isEmpty
        }
    }

    @MainActor
    private func assertEventually(
        timeout: Duration = .seconds(3),
        pollInterval: Duration = .milliseconds(20),
        condition: @escaping () async -> Bool
    ) async {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout

        while clock.now < deadline {
            if await condition() {
                return
            }

            await Task.yield()
            try? await Task.sleep(for: pollInterval)
        }

        Issue.record("Condition was not met before timeout.")
    }
}
