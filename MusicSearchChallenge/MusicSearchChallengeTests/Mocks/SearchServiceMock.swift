//
//  SearchServiceMock.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
@testable import MusicSearchChallenge

actor SearchServiceMock: SearchServiceProtocol {
    struct SearchCall: Equatable {
        let term: String
        let limit: Int
        let offset: Int
    }

    var searchCalls: [SearchCall] = []
    var searchHandler: (@Sendable (String, Int, Int) async throws -> [Song])?

    func setSearchHandler(
        _ handler: @escaping @Sendable (String, Int, Int) async throws -> [Song]
    ) {
        searchHandler = handler
    }

    func search(term: String, limit: Int, offset: Int) async throws -> [Song] {
        searchCalls.append(SearchCall(term: term, limit: limit, offset: offset))

        guard let searchHandler else {
            fatalError("searchHandler not set on SearchServiceMock")
        }

        return try await searchHandler(term, limit, offset)
    }

    func fetchAlbum(collectionId: Int) async throws -> [Song] {
        fatalError("fetchAlbum should not be called in these tests")
    }
}
