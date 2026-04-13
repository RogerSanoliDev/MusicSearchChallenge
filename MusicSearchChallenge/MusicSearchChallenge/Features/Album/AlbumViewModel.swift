//
//  AlbumViewModel.swift
//  MusicSearchChallenge
//
//  Created by Codex on 10/04/26.
//

import Observation
import SongPlayer

@MainActor
@Observable
final class AlbumViewModel {
    enum State: Equatable {
        case loading
        case success
        case empty
        case error
    }

    let song: Song
    var state: State = .loading
    var songs: [Song] = []

    @ObservationIgnored
    private let searchService: SearchServiceProtocol
    @ObservationIgnored
    private var hasLoaded = false

    init(
        song: Song,
        searchService: SearchServiceProtocol = SearchService()
    ) {
        self.song = song
        self.searchService = searchService
    }

    func fetchAlbum() async {
        guard !hasLoaded else { return }

        hasLoaded = true

        do {
            let albumSongs = try await searchService.fetchAlbum(collectionId: song.collectionID)
            songs = albumSongs
            state = albumSongs.isEmpty ? .empty : .success
        } catch is CancellationError {
            songs = []
            hasLoaded = false
            state = .loading
        } catch {
            songs = []
            state = .error
        }
    }
}
