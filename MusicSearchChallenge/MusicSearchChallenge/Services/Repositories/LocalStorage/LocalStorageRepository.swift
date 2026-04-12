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
    func save(song: Song) throws
    func saveRecentPlayed(song: Song) throws
    func searchSongs(term: String, limit: Int, offset: Int) throws -> [Song]
    func fetchRecentPlayed() throws -> [Song]
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

    func save(song: Song) throws {
        try upsertStoredSong(with: song) { storedSong in
            storedSong.updateFromSearch(song: song)
        } insert: {
            StoredSong(song: song)
        }

        try pruneStoredSongsIfNeeded()
        try modelContext.save()
    }

    func saveRecentPlayed(song: Song) throws {
        let now = Date()

        try upsertStoredSong(with: song) { storedSong in
            storedSong.updateFromRecentPlayed(song: song, savedAt: now, lastPlayedAt: now)
        } insert: {
            StoredSong(song: song, savedAt: now, lastPlayedAt: now)
        }

        try pruneStoredSongsIfNeeded()
        try modelContext.save()
    }

    func searchSongs(term: String, limit: Int, offset: Int) throws -> [Song] {
        let normalizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTerm.isEmpty, limit > 0, offset >= 0 else { return [] }

        return try fetchAllStoredSongs()
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

    func fetchRecentPlayed() throws -> [Song] {
        try fetchAllStoredSongs()
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
    ) throws {
        let trackID = song.trackID
        let existingSong = try modelContext.fetch(
            FetchDescriptor<StoredSong>(
                predicate: #Predicate { storedSong in
                    storedSong.trackID == trackID
                }
            )
        ).first

        if let existingSong {
            update(existingSong)
        } else {
            modelContext.insert(insert())
        }
    }

    private func fetchAllStoredSongs() throws -> [StoredSong] {
        let descriptor = FetchDescriptor<StoredSong>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func pruneStoredSongsIfNeeded() throws {
        let storedSongs = try fetchAllStoredSongs()

        guard storedSongs.count > maxStoredSongs else { return }

        for song in storedSongs.dropFirst(maxStoredSongs) {
            modelContext.delete(song)
        }
    }
}
