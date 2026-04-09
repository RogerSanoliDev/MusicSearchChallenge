//
//  APISearchRepository.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Networking

protocol APISearchRepositoryProtocol: Sendable {
    nonisolated func search(term: String, limit: Int, offset: Int) async throws -> SearchResponseDTO
    nonisolated func fetchAlbum(collectionId: Int) async throws -> AlbumResponseDTO
}

final class APISearchRepository: APISearchRepositoryProtocol {
    private let client: APIClientProtocol
    
    nonisolated init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    nonisolated func search(term: String, limit: Int, offset: Int) async throws -> SearchResponseDTO {
        try await client.performRequest(endpoint: .search(term: term, limit: limit, offset: offset))
    }
    
    nonisolated func fetchAlbum(collectionId: Int) async throws -> AlbumResponseDTO {
        try await client.performRequest(endpoint: .fetchAlbum(collectionId: collectionId))
    }
}

fileprivate extension Endpoint {
    static func search(term: String, limit: Int, offset: Int) -> Endpoint {
        Endpoint(path: "search",
                 queryItems: [
                    "term": term,
                    "entity": "song",
                    "limit": String(limit),
                    "offset": String(offset)
                 ])
    }
    
    static func fetchAlbum(collectionId: Int) -> Endpoint {
        Endpoint(path: "lookup",
                 queryItems: [
                    "id": String(collectionId),
                    "entity": "song"
                 ])
    }
}
