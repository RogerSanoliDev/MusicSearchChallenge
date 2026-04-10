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

    var searchCalls: [SearchCall] = []
    var fetchAlbumCalls: [FetchAlbumCall] = []
    var searchHandler: (@Sendable (String, Int, Int) async throws -> [Song])?
    var fetchAlbumHandler: (@Sendable (Int) async throws -> [Song])?

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

    func search(term: String, limit: Int, offset: Int) async throws -> [Song] {
        searchCalls.append(SearchCall(term: term, limit: limit, offset: offset))

        guard let searchHandler else {
            fatalError("searchHandler not set on SearchServiceMock")
        }

        return try await searchHandler(term, limit, offset)
    }

    func fetchAlbum(collectionId: Int) async throws -> [Song] {
        fetchAlbumCalls.append(FetchAlbumCall(collectionId: collectionId))

        guard let fetchAlbumHandler else {
            fatalError("fetchAlbumHandler not set on SearchServiceMock")
        }

        return try await fetchAlbumHandler(collectionId)
    }
}
