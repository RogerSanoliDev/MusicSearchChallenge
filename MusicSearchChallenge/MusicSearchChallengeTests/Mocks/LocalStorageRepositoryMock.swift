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
    struct SearchCall: Equatable {
        let term: String
        let limit: Int
        let offset: Int
    }

    private(set) var savedSongs: [Song] = []
    private(set) var savedRecentPlayedSongs: [Song] = []
    private(set) var removedRecentPlayedSongs: [Song] = []
    private(set) var searchCalls: [SearchCall] = []
    var searchSongsResult: Result<[Song], Error> = .success([])
    var recentPlayedResult: Result<[Song], Error> = .success([])

    func save(song: Song) async throws {
        savedSongs.append(song)
    }

    func save(songs: [Song]) async throws {
        savedSongs.append(contentsOf: songs)
    }

    func saveRecentPlayed(song: Song) async throws {
        savedRecentPlayedSongs.append(song)
    }

    func removeRecentPlayed(song: Song) async throws {
        removedRecentPlayedSongs.append(song)
    }

    func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        searchCalls.append(SearchCall(term: term, limit: limit, offset: offset))
        return try searchSongsResult.get()
    }

    func fetchRecentPlayed() async throws -> [Song] {
        try recentPlayedResult.get()
    }
}
