//
//  SearchServiceTests.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Testing
@testable import MusicSearchChallenge
import Networking

struct SearchServiceTests {
    @Test
    @MainActor
    func search_callsRepository_withCorrectParameters_andMapsResponse() async throws {
        let mock = APISearchRepositoryMock()
        let sut = SearchService(apiRepository: mock)
        await mock.setSearchResult(.success(
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

        let result = try await sut.search(term: "beatles", limit: 10, offset: 20)

        #expect(await mock.searchCallCount == 1)
        #expect(await mock.receivedSearchTerm == "beatles")
        #expect(await mock.receivedSearchLimit == 10)
        #expect(await mock.receivedSearchOffset == 20)

        #expect(result.count == 1)
        let firstSong = try #require(result.first)
        #expect(firstSong.trackID == 1)
        #expect(firstSong.artistName == "The Beatles")
        #expect(firstSong.collectionName == "Abbey Road")
        #expect(firstSong.trackName == "Something")
    }

    @Test
    @MainActor
    func search_propagatesRepositoryError() async {
        let mock = APISearchRepositoryMock()
        let sut = SearchService(apiRepository: mock)
        await mock.setSearchResult(.failure(NetworkError.invalidStatusCode(errorCode: 500)))

        await #expect(throws: NetworkError.self) {
            try await sut.search(term: "beatles", limit: 10, offset: 0)
        }
    }

    @Test
    @MainActor
    func fetchAlbum_callsRepository_withCorrectParameters_andMapsResponse() async throws {
        let mock = APISearchRepositoryMock()
        let sut = SearchService(apiRepository: mock)
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
        let sut = SearchService(apiRepository: mock)
        await mock.setFetchAlbumResult(.failure(NetworkError.invalidHTTPResponse))

        await #expect(throws: NetworkError.self) {
            try await sut.fetchAlbum(collectionId: 123)
        }
    }
}
