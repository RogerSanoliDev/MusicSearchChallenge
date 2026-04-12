//
//  LocalStorageRepositoryMock.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import Foundation
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
final class LocalStorageRepositoryMock: LocalStorageRepositoryProtocol {
    private(set) var savedSongs: [Song] = []
    private(set) var savedRecentPlayedSongs: [Song] = []
    var searchSongsResult: Result<[Song], Error> = .success([])
    var recentPlayedResult: Result<[Song], Error> = .success([])

    func save(song: Song) throws {
        savedSongs.append(song)
    }

    func saveRecentPlayed(song: Song) throws {
        savedRecentPlayedSongs.append(song)
    }

    func searchSongs(term: String, limit: Int, offset: Int) throws -> [Song] {
        try searchSongsResult.get()
    }

    func fetchRecentPlayed() throws -> [Song] {
        try recentPlayedResult.get()
    }
}
