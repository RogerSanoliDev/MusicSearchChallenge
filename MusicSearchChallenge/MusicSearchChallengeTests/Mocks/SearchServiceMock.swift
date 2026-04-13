//
//  SearchServiceMock.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
import SongPlayer
@testable import MusicSearchChallenge

actor SearchServiceMock: SearchServiceProtocol {
    struct SearchCall: Equatable {
        let term: String
        let limit: Int
        let offset: Int
    }

    struct FetchAlbumCall: Equatable {
        let collectionId: Int
    }

    struct SaveRecentPlayedCall: Equatable {
        let song: Song
    }

    struct RemoveRecentPlayedCall: Equatable {
        let song: Song
    }

    var searchCalls: [SearchCall] = []
    var fetchAlbumCalls: [FetchAlbumCall] = []
    var saveRecentPlayedCalls: [SaveRecentPlayedCall] = []
    var removeRecentPlayedCalls: [RemoveRecentPlayedCall] = []
    var fetchRecentPlayedCallCount = 0
    var queuedFetchRecentPlayedResults: [[Song]] = []
    var searchHandler: (@Sendable (String, Int, Int) async throws -> [Song])?
    var fetchAlbumHandler: (@Sendable (Int) async throws -> [Song])?
    var fetchRecentPlayedHandler: (@Sendable () async throws -> [Song])?

    func setSearchHandler(
        _ handler: @escaping @Sendable (String, Int, Int) async throws -> [Song]
    ) {
        searchHandler = handler
    }

    func setFetchAlbumHandler(
        _ handler: @escaping @Sendable (Int) async throws -> [Song]
    ) {
        fetchAlbumHandler = handler
    }

    func setFetchRecentPlayedHandler(
        _ handler: @escaping @Sendable () async throws -> [Song]
    ) {
        fetchRecentPlayedHandler = handler
    }

    func enqueueFetchRecentPlayedResults(_ results: [[Song]]) {
        queuedFetchRecentPlayedResults.append(contentsOf: results)
    }

    func getFetchRecentPlayedCallCount() -> Int {
        fetchRecentPlayedCallCount
    }

    func search(term: String, limit: Int, offset: Int) async throws -> [Song] {
        searchCalls.append(SearchCall(term: term, limit: limit, offset: offset))

        guard let searchHandler else {
            return []
        }

        return try await searchHandler(term, limit, offset)
    }

    func fetchAlbum(collectionId: Int) async throws -> [Song] {
        fetchAlbumCalls.append(FetchAlbumCall(collectionId: collectionId))

        guard let fetchAlbumHandler else {
            return []
        }

        return try await fetchAlbumHandler(collectionId)
    }

    func saveRecentPlayed(song: Song) async throws {
        saveRecentPlayedCalls.append(SaveRecentPlayedCall(song: song))
    }

    func removeRecentPlayed(song: Song) async throws {
        removeRecentPlayedCalls.append(RemoveRecentPlayedCall(song: song))
    }

    func fetchRecentPlayed() async throws -> [Song] {
        fetchRecentPlayedCallCount += 1

        if !queuedFetchRecentPlayedResults.isEmpty {
            return queuedFetchRecentPlayedResults.removeFirst()
        }

        guard let fetchRecentPlayedHandler else {
            return []
        }

        return try await fetchRecentPlayedHandler()
    }
}
