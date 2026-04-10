//
//  SearchService.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import SongPlayer

protocol SearchServiceProtocol: Sendable {
    nonisolated func search(term: String, limit: Int, offset: Int) async throws -> [Song]
    nonisolated func fetchAlbum(collectionId: Int) async throws -> [Song]
}

final class SearchService: SearchServiceProtocol {
    private let apiRepository: APISearchRepositoryProtocol
    
    nonisolated init(apiRepository: APISearchRepositoryProtocol = APISearchRepository()) {
        self.apiRepository = apiRepository
    }
    
    nonisolated func search(term: String, limit: Int, offset: Int) async throws -> [Song] {
        let searchResponse = try await apiRepository.search(term: term, limit: limit, offset: offset)
        return searchResponse.results.map { Song(dto: $0) }
    }
    
    nonisolated func fetchAlbum(collectionId: Int) async throws -> [Song] {
        let albumResponse = try await apiRepository.fetchAlbum(collectionId: collectionId)
        return albumResponse.songs.map { Song(dto: $0) }
    }
}
