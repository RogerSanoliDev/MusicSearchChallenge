//
//  SearchServiceTests.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Testing
@testable import MusicSearchChallenge
import Networking
import SongPlayer

struct SearchServiceTests {
    @Test
    @MainActor
    func search_returnsCachedSongs_withoutCallingAPI_whenLocalStorageHasEnoughResults() async throws {
        let apiRepository = APISearchRepositoryMock()
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(
            apiRepository: apiRepository,
            localStorageRepository: localStorageRepository
        )
        let cachedSongs = [
            Song.stub(trackID: 1, artistName: "The Beatles", collectionName: "Abbey Road", trackName: "Something"),
            Song.stub(trackID: 2, artistName: "The Beatles", collectionName: "Abbey Road", trackName: "Come Together")
        ]
        localStorageRepository.searchSongsResult = .success(cachedSongs)

        let result = try await sut.search(term: "beatles", limit: 2, offset: 0)

        #expect(localStorageRepository.searchCalls == [
            .init(term: "beatles", limit: 2, offset: 0)
        ])
        #expect(await apiRepository.searchCallCount == 0)
        #expect(result == cachedSongs)
    }

    @Test
    @MainActor
    func search_fetchesFromAPI_andCachesResponse_whenLocalStorageDoesNotHaveEnoughResults() async throws {
        let apiRepository = APISearchRepositoryMock()
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(
            apiRepository: apiRepository,
            localStorageRepository: localStorageRepository
        )
        localStorageRepository.searchSongsResult = .success([])
        await apiRepository.setSearchResult(.success(
            SearchResponseDTO(
                results: [
                    .stub(
                        collectionId: 99,
                        trackId: 1,
                        artistName: "The Beatles",
                        collectionName: "Abbey Road",
                        trackName: "Something"
                    )
                ]
            )
        ))

        let result = try await sut.search(term: "beatles", limit: 10, offset: 0)

        #expect(localStorageRepository.searchCalls == [
            .init(term: "beatles", limit: 10, offset: 0)
        ])
        #expect(await apiRepository.searchCallCount == 1)
        #expect(await apiRepository.receivedSearchTerm == "beatles")
        #expect(await apiRepository.receivedSearchLimit == 10)
        #expect(await apiRepository.receivedSearchOffset == 0)
        await assertEventually {
            localStorageRepository.savedSongs == result
        }

        #expect(result.count == 1)
        let firstSong = try #require(result.first)
        #expect(firstSong.trackID == 1)
        #expect(firstSong.artistName == "The Beatles")
        #expect(firstSong.collectionName == "Abbey Road")
        #expect(firstSong.trackName == "Something")
    }

    @Test
    @MainActor
    func search_returnsCachedSongs_whenAPIRequestFails() async throws {
        let apiRepository = APISearchRepositoryMock()
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(
            apiRepository: apiRepository,
            localStorageRepository: localStorageRepository
        )
        let cachedSongs = [
            Song.stub(trackID: 1, artistName: "The Beatles", trackName: "Something")
        ]
        localStorageRepository.searchSongsResult = .success(cachedSongs)
        await apiRepository.setSearchResult(.failure(NetworkError.invalidStatusCode(errorCode: 500)))

        let result = try await sut.search(term: "beatles", limit: 10, offset: 0)

        #expect(await apiRepository.searchCallCount == 1)
        #expect(result == cachedSongs)
    }

    @Test
    @MainActor
    func search_propagatesRepositoryError_whenCacheIsEmpty() async {
        let apiRepository = APISearchRepositoryMock()
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(
            apiRepository: apiRepository,
            localStorageRepository: localStorageRepository
        )
        localStorageRepository.searchSongsResult = .success([])
        await apiRepository.setSearchResult(.failure(NetworkError.invalidStatusCode(errorCode: 500)))

        await #expect(throws: NetworkError.self) {
            try await sut.search(term: "beatles", limit: 10, offset: 0)
        }
    }

    @Test
    @MainActor
    func fetchAlbum_callsRepository_withCorrectParameters_andMapsResponse() async throws {
        let mock = APISearchRepositoryMock()
        let sut = makeSUT(apiRepository: mock)
        await mock.setFetchAlbumResult(.success(
            AlbumResponseDTO(
                songs: [
                    .stub(
                        collectionId: 88,
                        trackId: 123,
                        artistName: "Daft Punk",
                        collectionName: "Discovery",
                        trackName: "One More Time"
                    )
                ]
            )
        ))

        let result = try await sut.fetchAlbum(collectionId: 456)

        #expect(await mock.fetchAlbumCallCount == 1)
        #expect(await mock.receivedCollectionId == 456)

        #expect(result.count == 1)
        let firstSong = try #require(result.first)
        #expect(firstSong.collectionID == 88)
        #expect(firstSong.trackID == 123)
        #expect(firstSong.artistName == "Daft Punk")
        #expect(firstSong.collectionName == "Discovery")
        #expect(firstSong.trackName == "One More Time")
    }

    @Test
    @MainActor
    func fetchAlbum_propagatesRepositoryError() async {
        let mock = APISearchRepositoryMock()
        let sut = makeSUT(apiRepository: mock)
        await mock.setFetchAlbumResult(.failure(NetworkError.invalidHTTPResponse))

        await #expect(throws: NetworkError.self) {
            try await sut.fetchAlbum(collectionId: 123)
        }
    }

    @Test
    @MainActor
    func saveRecentPlayed_callsLocalStorageRepositoryWithSong() async throws {
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(localStorageRepository: localStorageRepository)
        let song = Song.stub(trackID: 123, trackName: "One More Time")

        try await sut.saveRecentPlayed(song: song)

        #expect(localStorageRepository.savedRecentPlayedSongs == [song])
    }

    @Test
    @MainActor
    func removeRecentPlayed_callsLocalStorageRepositoryWithSong() async throws {
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(localStorageRepository: localStorageRepository)
        let song = Song.stub(trackID: 123, trackName: "One More Time")

        try await sut.removeRecentPlayed(song: song)

        #expect(localStorageRepository.removedRecentPlayedSongs == [song])
    }

    @Test
    @MainActor
    func fetchRecentPlayed_returnsSongsFromLocalStorageRepository() async throws {
        let localStorageRepository = LocalStorageRepositoryMock()
        let sut = makeSUT(localStorageRepository: localStorageRepository)
        let expectedSongs = [
            Song.stub(trackID: 1, trackName: "First"),
            Song.stub(trackID: 2, trackName: "Second")
        ]
        localStorageRepository.recentPlayedResult = .success(expectedSongs)

        let result = try await sut.fetchRecentPlayed()

        #expect(result == expectedSongs)
    }

    @MainActor
    private func makeSUT(
        apiRepository: APISearchRepositoryProtocol = APISearchRepositoryMock(),
        localStorageRepository: LocalStorageRepositoryMock? = nil,
        cachePersistenceDelay: Duration = .zero
    ) -> SearchService {
        let localStorageRepository = localStorageRepository ?? LocalStorageRepositoryMock()

        return SearchService(
            apiRepository: apiRepository,
            localStorageRepository: localStorageRepository,
            cachePersistenceDelay: cachePersistenceDelay
        )
    }

    @MainActor
    private func assertEventually(
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(20),
        condition: @escaping @MainActor () -> Bool
    ) async {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout

        while clock.now < deadline {
            if condition() {
                return
            }

            await Task.yield()
            try? await Task.sleep(for: pollInterval)
        }

        Issue.record("Condition was not met before timeout.")
    }
}
