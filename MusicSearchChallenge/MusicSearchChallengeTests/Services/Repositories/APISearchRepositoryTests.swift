//
//  APISearchRepositoryTests.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Testing
@testable import MusicSearchChallenge
import Foundation
@testable import Networking

struct APISearchRepositoryTests {
    @Test
    @MainActor
    func search_callsClient_withCorrectEndpoint_andReturnsResponse() async throws {
        let mock = APIClientMock()
        let sut = APISearchRepository(client: mock)
        let expectedResponse = SearchResponseDTO(results: [.stub(trackId: 1)])
        await mock.setResult(.success(expectedResponse))

        let result = try await sut.search(term: "beatles", limit: 10, offset: 20)

        #expect(await mock.performRequestCount == 1)

        let endpoint = try #require(await mock.receivedEndpoint)
        let url = try #require(endpoint.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })

        #expect(components.path == "/search")
        #expect(queryItems["term"] == "beatles")
        #expect(queryItems["entity"] == "song")
        #expect(queryItems["limit"] == "10")
        #expect(queryItems["offset"] == "20")
        let results = result.results
        let firstResultTrackId = results.first?.trackId
        #expect(results.count == 1)
        #expect(firstResultTrackId == 1)
    }

    @Test
    @MainActor
    func search_propagatesClientError() async {
        let mock = APIClientMock()
        let sut = APISearchRepository(client: mock)
        let expectedError = NetworkError.invalidStatusCode(errorCode: 500)
        await mock.setResult(.failure(expectedError))

        await #expect(throws: NetworkError.self) {
            try await sut.search(term: "beatles", limit: 10, offset: 0)
        }
    }

    @Test
    @MainActor
    func fetchAlbum_callsClient_withCorrectEndpoint_andReturnsResponse() async throws {
        let mock = APIClientMock()
        let sut = APISearchRepository(client: mock)
        let expectedResponse = AlbumResponseDTO(songs: [.stub(trackId: 123)])
        await mock.setResult(.success(expectedResponse))

        let result = try await sut.fetchAlbum(collectionId: 456)

        #expect(await mock.performRequestCount == 1)

        let endpoint = try #require(await mock.receivedEndpoint)
        let url = try #require(endpoint.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })

        #expect(components.path == "/lookup")
        #expect(queryItems["id"] == "456")
        #expect(queryItems["entity"] == "song")
        let songs = result.songs
        let firstSongTrackId = songs.first?.trackId
        #expect(songs.count == 1)
        #expect(firstSongTrackId == 123)
    }

    @Test
    @MainActor
    func fetchAlbum_propagatesClientError() async {
        let mock = APIClientMock()
        let sut = APISearchRepository(client: mock)
        let expectedError = NetworkError.invalidHTTPResponse
        await mock.setResult(.failure(expectedError))

        await #expect(throws: NetworkError.self) {
            try await sut.fetchAlbum(collectionId: 123)
        }
    }
}
