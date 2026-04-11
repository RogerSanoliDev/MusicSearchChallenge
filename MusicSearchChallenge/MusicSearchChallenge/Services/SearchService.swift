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
        /**
         At the time I was developing this code challenge, there was no officially documented way to paginate iTunes Search API requests.
         I found some online forum discussions mentioning an `offset` parameter that reportedly worked for search requests, but not for lookup requests.
         
         In my tests, this parameter did not work. The following requests returned the same results:
         https://itunes.apple.com/search?term=haken&entity=song&offset=0&limit=10
         https://itunes.apple.com/search?term=haken&entity=song&offset=10&limit=10
         
         To validate the app's pagination behavior, I ended up increasing the limit on each pagination request, keeping `offset` at `0`, and deduplicating results by `trackID`.
         I left the intended search call commented out below.
         */
        
        let searchResponse = try await apiRepository.search(term: term, limit: limit+offset, offset: 0)
        //let searchResponse = try await apiRepository.search(term: term, limit: limit, offset: offset)
        return searchResponse.results.map { Song(dto: $0) }
    }
    
    nonisolated func fetchAlbum(collectionId: Int) async throws -> [Song] {
        let albumResponse = try await apiRepository.fetchAlbum(collectionId: collectionId)
        return albumResponse.songs.map { Song(dto: $0) }
    }
}
