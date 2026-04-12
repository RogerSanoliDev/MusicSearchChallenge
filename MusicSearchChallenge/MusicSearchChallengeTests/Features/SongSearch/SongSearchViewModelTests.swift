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
    func handleViewAppear_withRecentPlayedSongs_setsRecentPlayedState() async throws {
        let mock = SearchServiceMock()
        let recentSongs = [
            Song.stub(trackID: 1, artistName: "Queen", trackName: "Bohemian Rhapsody")
        ]
        await mock.setFetchRecentPlayedHandler { recentSongs }

        let sut = SongSearchViewModel(searchService: mock)
        sut.handleViewAppear()

        await assertEventually {
            sut.state == .recentPlayed
                && sut.recentPlayedSongs == recentSongs
        }
    }

    @Test
    func handleViewAppear_withoutRecentPlayedSongs_keepsIdleState() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }

        let sut = SongSearchViewModel(searchService: mock)
        sut.handleViewAppear()

        await assertEventually {
            sut.state == .idle
                && sut.recentPlayedSongs.isEmpty
        }
    }

    @Test
    func searchText_performsSearchAfterDebounce_andUpdatesSuccessState() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
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
                && sut.hasMorePages
        }
    }

    @Test
    func searchText_withEmptyResults_setsEmptyState() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
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
        await mock.setFetchRecentPlayedHandler { [] }
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
        await mock.setFetchRecentPlayedHandler { [] }
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
    func searchText_whenCleared_restoresRecentPlayedStateWithoutSearching() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler {
            [.stub(trackID: 9, artistName: "Artist", trackName: "Recent Song")]
        }
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
                && sut.state == .recentPlayed
                && sut.songs.isEmpty
                && sut.recentPlayedSongs.map(\.trackID) == [9]
        }
    }

    @Test
    func searchText_whenCleared_refreshesRecentPlayedSongs() async throws {
        let mock = SearchServiceMock()
        let firstRecentSongs = [
            Song.stub(trackID: 1, artistName: "Artist", trackName: "Older Recent")
        ]
        let refreshedRecentSongs = [
            Song.stub(trackID: 2, artistName: "Artist", trackName: "Newest Recent")
        ]
        await mock.enqueueFetchRecentPlayedResults([firstRecentSongs, refreshedRecentSongs])
        await mock.setSearchHandler { _, _, _ in
            [.stub(trackID: 99, artistName: "Artist", trackName: "Search Result")]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )
        sut.handleViewAppear()

        await assertEventually {
            sut.state == .recentPlayed
                && sut.recentPlayedSongs == firstRecentSongs
        }

        sut.searchText = "query"

        await assertEventually {
            sut.state == .success
                && sut.songs.map(\.trackID) == [99]
        }

        sut.searchText = ""

        await assertEventually {
            let fetchRecentPlayedCallCount = await mock.getFetchRecentPlayedCallCount()
            return sut.state == .recentPlayed
                && sut.recentPlayedSongs == refreshedRecentSongs
                && fetchRecentPlayedCallCount == 2
        }
    }

    @Test
    func handleViewAppear_refreshesRecentPlayedSongs() async throws {
        let mock = SearchServiceMock()
        let firstRecentSongs = [
            Song.stub(trackID: 1, artistName: "Artist", trackName: "Older Recent")
        ]
        let refreshedRecentSongs = [
            Song.stub(trackID: 2, artistName: "Artist", trackName: "Newest Recent")
        ]
        await mock.enqueueFetchRecentPlayedResults([firstRecentSongs, refreshedRecentSongs])

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )
        sut.handleViewAppear()

        await assertEventually {
            sut.state == .recentPlayed
                && sut.recentPlayedSongs == firstRecentSongs
        }

        sut.searchText = "query"
        sut.handleViewAppear()

        await assertEventually {
            let fetchRecentPlayedCallCount = await mock.getFetchRecentPlayedCallCount()
            return sut.recentPlayedSongs == refreshedRecentSongs
                && fetchRecentPlayedCallCount == 2
        }
    }

    @Test
    func loadNextPageIfNeeded_appendsSongsAndUpdatesOffset() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        await mock.setSearchHandler { term, limit, offset in
            #expect(term == "queen")
            #expect(limit == 10)

            if offset == 0 {
                return (1...10).map {
                    .stub(trackID: $0, artistName: "Queen", trackName: "Song \($0)")
                }
            }

            #expect(offset == 10)
            return (11...20).map {
                .stub(trackID: $0, artistName: "Queen", trackName: "Song \($0)")
            }
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "queen"

        await assertEventually {
            sut.state == .success
                && sut.songs.count == 10
                && sut.hasMorePages
        }

        sut.loadNextPageIfNeeded()

        await assertEventually {
            let calls = await mock.searchCalls
            return calls.count == 2
                && calls.map(\.offset) == [0, 10]
                && sut.songs.count == 20
                && sut.songs.last?.trackID == 20
                && sut.hasMorePages
                && sut.isLoadingNextPage == false
        }
    }

    @Test
    func loadNextPageIfNeeded_whenNextPageAddsUniqueSongs_keepsPaginationEnabled() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        await mock.setSearchHandler { _, _, offset in
            if offset == 0 {
                return (1...10).map {
                    .stub(trackID: $0, artistName: "Queen", trackName: "Song \($0)")
                }
            }

            return [
                .stub(trackID: 11, artistName: "Queen", trackName: "Song 11"),
                .stub(trackID: 12, artistName: "Queen", trackName: "Song 12"),
            ]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "queen"

        await assertEventually {
            sut.state == .success
                && sut.songs.count == 10
                && sut.hasMorePages
        }

        sut.loadNextPageIfNeeded()

        await assertEventually {
            sut.songs.count == 12
                && sut.hasMorePages
                && sut.isLoadingNextPage == false
        }
    }

    @Test
    func loadNextPageIfNeeded_whenNextPageOnlyContainsDuplicates_stopsPagination() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        await mock.setSearchHandler { _, _, offset in
            if offset == 0 {
                return (1...10).map {
                    .stub(trackID: $0, artistName: "Queen", trackName: "Song \($0)")
                }
            }

            return (1...10).map {
                .stub(trackID: $0, artistName: "Queen", trackName: "Song \($0)")
            }
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "queen"

        await assertEventually {
            sut.state == .success
                && sut.songs.count == 10
                && sut.hasMorePages
        }

        sut.loadNextPageIfNeeded()

        await assertEventually {
            sut.songs.count == 10
                && sut.hasMorePages == false
                && sut.isLoadingNextPage == false
        }
    }

    @Test
    func reloadSearch_afterPagination_reloadsFirstPageAndResetsResults() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        await mock.setSearchHandler { _, _, offset in
            switch offset {
            case 0:
                return [
                    .stub(trackID: 101, artistName: "Queen", trackName: "Refreshed 1"),
                    .stub(trackID: 102, artistName: "Queen", trackName: "Refreshed 2"),
                ]
            case 10:
                return [
                    .stub(trackID: 201, artistName: "Queen", trackName: "Paged 1"),
                    .stub(trackID: 202, artistName: "Queen", trackName: "Paged 2"),
                ]
            default:
                Issue.record("Unexpected offset \(offset)")
                return []
            }
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )

        sut.searchText = "queen"

        await assertEventually {
            sut.state == .success
                && sut.songs.map(\.trackID) == [101, 102]
                && sut.hasMorePages
        }

        sut.loadNextPageIfNeeded()

        await assertEventually {
            sut.songs.map(\.trackID) == [101, 102, 201, 202]
                && sut.isLoadingNextPage == false
        }

        await sut.reloadSearch()

        await assertEventually {
            let calls = await mock.searchCalls
            return calls.map(\.offset) == [0, 10, 0]
                && sut.state == .success
                && sut.songs.map(\.trackID) == [101, 102]
                && sut.isLoadingNextPage == false
                && sut.hasMorePages
        }
    }

    @Test
    func reloadSearch_withBlankQuery_resetsToIdleWithoutRequest() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        await mock.setSearchHandler { _, _, _ in
            [.stub(trackID: 1, artistName: "Queen", trackName: "Bohemian Rhapsody")]
        }

        let sut = SongSearchViewModel(
            searchService: mock,
            searchDebounceDuration: .zero
        )
        sut.searchText = "   "
        sut.state = .success
        sut.songs = [.stub(trackID: 99, artistName: "Queen", trackName: "Old Song")]
        sut.hasMorePages = true
        sut.isLoadingNextPage = true

        await sut.reloadSearch()

        #expect(await mock.searchCalls.isEmpty)
        #expect(sut.state == .idle)
        #expect(sut.songs.isEmpty)
        #expect(sut.hasMorePages == false)
        #expect(sut.isLoadingNextPage == false)
    }

    @Test
    func currentSong_returnsSelectedSongWithoutSavingRecentPlayed() async throws {
        let mock = SearchServiceMock()
        await mock.setFetchRecentPlayedHandler { [] }
        let sut = SongSearchViewModel(searchService: mock)
        sut.state = .success
        sut.songs = [.stub(trackID: 42, artistName: "Muse", trackName: "Hysteria")]

        let selectedSong = sut.currentSong(at: 0)

        #expect(selectedSong?.trackID == 42)
        #expect(await mock.saveRecentPlayedCalls.isEmpty)
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
