//
//  SongPlayerContainerViewModel.swift
//  MusicSearchChallenge
//
//  Created by Codex on 12/04/26.
//

import Observation
import SongPlayer

@MainActor
@Observable
final class SongPlayerContainerViewModel {
    private(set) var songs: [Song]
    private(set) var startIndex: Int
    var currentSong: Song?

    @ObservationIgnored
    private let searchService: SearchServiceProtocol

    init(
        songs: [Song],
        startIndex: Int,
        searchService: SearchServiceProtocol = SearchService()
    ) {
        self.songs = songs
        self.startIndex = startIndex
        self.currentSong = songs.indices.contains(startIndex) ? songs[startIndex] : songs.first
        self.searchService = searchService
    }

    var playerViewID: String {
        let trackIDs = songs.map(\.trackID).map(String.init).joined(separator: "-")
        return "\(trackIDs)-\(startIndex)"
    }

    var selectedSong: Song? {
        currentSong
    }

    func onAppear() async {
        guard let currentSong else { return }
        await saveRecentPlayed(song: currentSong)
    }

    func handleSongChange(_ song: Song) async {
        currentSong = song
        await saveRecentPlayed(song: song)
    }

    func saveRecentPlayed(song: Song) async {
        try? await searchService.saveRecentPlayed(song: song)
    }
}
