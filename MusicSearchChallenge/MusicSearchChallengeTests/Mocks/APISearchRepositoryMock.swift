//
//  APISearchRepositoryMock.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation
@testable import MusicSearchChallenge

actor APISearchRepositoryMock: APISearchRepositoryProtocol {
    var searchCallCount = 0
    var fetchAlbumCallCount = 0

    var receivedSearchTerm: String?
    var receivedSearchLimit: Int?
    var receivedSearchOffset: Int?
    var receivedCollectionId: Int?

    var searchResult: Result<SearchResponseDTO, Error>?
    var fetchAlbumResult: Result<AlbumResponseDTO, Error>?

    func setSearchResult(_ result: Result<SearchResponseDTO, Error>) {
        searchResult = result
    }

    func setFetchAlbumResult(_ result: Result<AlbumResponseDTO, Error>) {
        fetchAlbumResult = result
    }

    func search(term: String, limit: Int, offset: Int) async throws -> SearchResponseDTO {
        searchCallCount += 1
        receivedSearchTerm = term
        receivedSearchLimit = limit
        receivedSearchOffset = offset

        guard let searchResult else {
            fatalError("searchResult not set on APISearchRepositoryMock")
        }

        switch searchResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func fetchAlbum(collectionId: Int) async throws -> AlbumResponseDTO {
        fetchAlbumCallCount += 1
        receivedCollectionId = collectionId

        guard let fetchAlbumResult else {
            fatalError("fetchAlbumResult not set on APISearchRepositoryMock")
        }

        switch fetchAlbumResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
