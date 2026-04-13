//
//  SearchService.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import SongPlayer

protocol SearchServiceProtocol: Sendable {
    func search(term: String, limit: Int, offset: Int) async throws -> [Song]
    func fetchAlbum(collectionId: Int) async throws -> [Song]
    func saveRecentPlayed(song: Song) async throws
    func removeRecentPlayed(song: Song) async throws
    func fetchRecentPlayed() async throws -> [Song]
}

@MainActor
final class SearchService: SearchServiceProtocol {
    private let apiRepository: APISearchRepositoryProtocol
    private let localStorageRepository: LocalStorageRepositoryProtocol
    private let cachePersistenceDelay: Duration
    private var pendingSongsByTrackID: [Int: Song] = [:]
    private var cachePersistenceTask: Task<Void, Never>?
    
    init(
        apiRepository: APISearchRepositoryProtocol = APISearchRepository(),
        localStorageRepository: LocalStorageRepositoryProtocol = LocalStorageRepositoryFactory.makeDefaultRepository(),
        cachePersistenceDelay: Duration = .seconds(1)
    ) {
        self.apiRepository = apiRepository
        self.localStorageRepository = localStorageRepository
        self.cachePersistenceDelay = cachePersistenceDelay
    }

    deinit {
        cachePersistenceTask?.cancel()
    }
    
    func search(term: String, limit: Int, offset: Int) async throws -> [Song] {
        let cachedSongs = try? await fetchCachedSongs(term: term, limit: limit, offset: offset)
        
        if let cachedSongs, cachedSongs.count >= limit {
            return cachedSongs
        }
        
        do {
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
            let songs = searchResponse.results.map { Song(dto: $0) }
            persistSongsInCache(songs)
            return songs
        } catch {
            if let cachedSongs, !cachedSongs.isEmpty {
                return cachedSongs
            }
            
            throw error
        }
    }
    
    func fetchAlbum(collectionId: Int) async throws -> [Song] {
        let albumResponse = try await apiRepository.fetchAlbum(collectionId: collectionId)
        return albumResponse.songs.map { Song(dto: $0) }
    }
    
    func saveRecentPlayed(song: Song) async throws {
        try await localStorageRepository.saveRecentPlayed(song: song)
    }

    func removeRecentPlayed(song: Song) async throws {
        try await localStorageRepository.removeRecentPlayed(song: song)
    }
    
    func fetchRecentPlayed() async throws -> [Song] {
        try await localStorageRepository.fetchRecentPlayed()
    }
    
    private func fetchCachedSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        try await localStorageRepository.searchSongs(term: term, limit: limit, offset: offset)
    }
    
    private func persistSongsInCache(_ songs: [Song]) {
        for song in songs {
            pendingSongsByTrackID[song.trackID] = song
        }

        cachePersistenceTask?.cancel()

        let localStorageRepository = self.localStorageRepository
        let cachePersistenceDelay = self.cachePersistenceDelay

        cachePersistenceTask = Task(priority: .background) { [weak self] in
            do {
                try await Task.sleep(for: cachePersistenceDelay)
                guard !Task.isCancelled else { return }

                let songsToPersist = await MainActor.run { () -> [Song] in
                    guard let self else { return [] }

                    let songs = Array(self.pendingSongsByTrackID.values)
                    self.pendingSongsByTrackID.removeAll()
                    self.cachePersistenceTask = nil
                    return songs
                }

                guard !songsToPersist.isEmpty else { return }
                try? await localStorageRepository.save(songs: songsToPersist)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }
}
