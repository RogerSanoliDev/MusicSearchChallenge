//
//  LocalStorageRepository.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import Foundation
import SwiftData
import SongPlayer

@MainActor
protocol LocalStorageRepositoryProtocol: Sendable {
    func save(song: Song) async throws
    func save(songs: [Song]) async throws
    func saveRecentPlayed(song: Song) async throws
    func removeRecentPlayed(song: Song) async throws
    func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song]
    func fetchRecentPlayed() async throws -> [Song]
}

@MainActor
final class LocalStorageRepository: LocalStorageRepositoryProtocol {
    private let modelContext: ModelContext
    private let maxStoredSongs: Int
    private let maxRecentPlayedSongs: Int

    init(
        modelContext: ModelContext,
        maxStoredSongs: Int = 200,
        maxRecentPlayedSongs: Int = 10
    ) {
        self.modelContext = modelContext
        self.maxStoredSongs = maxStoredSongs
        self.maxRecentPlayedSongs = maxRecentPlayedSongs
    }

    func save(song: Song) async throws {
        try await save(songs: [song])
    }

    func save(songs: [Song]) async throws {
        guard !songs.isEmpty else { return }

        for song in songs {
            try await upsertStoredSong(with: song) { storedSong in
                storedSong.updateFromSearch(song: song)
            } insert: {
                StoredSong(song: song)
            }
        }

        try await pruneStoredSongsIfNeeded()
        try modelContext.save()
    }

    func saveRecentPlayed(song: Song) async throws {
        let now = Date()

        try await upsertStoredSong(with: song) { storedSong in
            storedSong.updateFromRecentPlayed(song: song, savedAt: now, lastPlayedAt: now)
        } insert: {
            StoredSong(song: song, savedAt: now, lastPlayedAt: now)
        }

        try await pruneStoredSongsIfNeeded()
        try modelContext.save()
    }

    func removeRecentPlayed(song: Song) async throws {
        guard let storedSong = try await fetchStoredSong(trackID: song.trackID) else { return }
        storedSong.lastPlayedAt = nil
        try modelContext.save()
    }

    func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        let normalizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTerm.isEmpty, limit > 0, offset >= 0 else { return [] }

        return try await fetchAllStoredSongs()
            .filter { storedSong in
                storedSong.trackName.localizedCaseInsensitiveContains(normalizedTerm)
                    || storedSong.artistName.localizedCaseInsensitiveContains(normalizedTerm)
                    || storedSong.collectionName.localizedCaseInsensitiveContains(normalizedTerm)
            }
            .sorted { lhs, rhs in
                if lhs.savedAt == rhs.savedAt {
                    return lhs.trackName.localizedCaseInsensitiveCompare(rhs.trackName) == .orderedAscending
                }

                return lhs.savedAt > rhs.savedAt
            }
            .dropFirst(offset)
            .prefix(limit)
            .map(\.song)
    }

    func fetchRecentPlayed() async throws -> [Song] {
        try await fetchAllStoredSongs()
            .filter { $0.lastPlayedAt != nil }
            .sorted { lhs, rhs in
                (lhs.lastPlayedAt ?? .distantPast) > (rhs.lastPlayedAt ?? .distantPast)
            }
            .prefix(maxRecentPlayedSongs)
            .map(\.song)
    }

    private func upsertStoredSong(
        with song: Song,
        update: (StoredSong) -> Void,
        insert: () -> StoredSong
    )  async throws {
        let existingSong = try await fetchStoredSong(trackID: song.trackID)

        if let existingSong {
            update(existingSong)
        } else {
            modelContext.insert(insert())
        }
    }

    private func fetchStoredSong(trackID: Int) async throws -> StoredSong? {
        try modelContext.fetch(
            FetchDescriptor<StoredSong>(
                predicate: #Predicate { storedSong in
                    storedSong.trackID == trackID
                }
            )
        ).first
    }

    private func fetchAllStoredSongs() async throws -> [StoredSong] {
        let descriptor = FetchDescriptor<StoredSong>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func pruneStoredSongsIfNeeded() async throws {
        let storedSongs = try await fetchAllStoredSongs()
        let recentPlayedSongs = storedSongs
            .filter { $0.lastPlayedAt != nil }
            .sorted { lhs, rhs in
                (lhs.lastPlayedAt ?? .distantPast) < (rhs.lastPlayedAt ?? .distantPast)
            }

        if recentPlayedSongs.count > maxRecentPlayedSongs {
            let recentSongsToClear = recentPlayedSongs.prefix(recentPlayedSongs.count - maxRecentPlayedSongs)

            for song in recentSongsToClear {
                song.lastPlayedAt = nil
            }
        }

        let songsToDeleteCount = storedSongs.count - maxStoredSongs
        guard songsToDeleteCount > 0 else { return }

        let nonRecentSongsByOldestSavedAt = storedSongs
            .filter { $0.lastPlayedAt == nil }
            .sorted { lhs, rhs in
                return lhs.savedAt < rhs.savedAt
            }

        for song in nonRecentSongsByOldestSavedAt.prefix(songsToDeleteCount) {
            modelContext.delete(song)
        }
    }
}
