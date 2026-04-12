//
//  LocalStorageRepositoryTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import SwiftData
import Testing
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
struct LocalStorageRepositoryTests {
    @Test
    func save_persistsSearchedSong_andDoesNotAddItToRecentPlayed() throws {
        let sut = try makeSUT()
        let song = Song.stub(trackID: 1, artistName: "Queen", trackName: "Bohemian Rhapsody")

        try sut.save(song: song)

        let foundSongs = try sut.searchSongs(term: "bohemian", limit: 10, offset: 0)
        let recentSongs = try sut.fetchRecentPlayed()

        #expect(foundSongs.count == 1)
        #expect(foundSongs.first == song)
        #expect(recentSongs.isEmpty)
    }

    @Test
    func saveRecentPlayed_persistsSong_andReturnsItInRecents() throws {
        let sut = try makeSUT()
        let song = Song.stub(trackID: 1, artistName: "Queen", trackName: "Bohemian Rhapsody")

        try sut.saveRecentPlayed(song: song)

        let recentSongs = try sut.fetchRecentPlayed()

        #expect(recentSongs.count == 1)
        #expect(recentSongs.first == song)
    }

    @Test
    func saveRecentPlayed_whenSongAlreadyExists_updatesIt_andMovesItToTopOfRecents() throws {
        let sut = try makeSUT()
        let firstVersion = Song.stub(trackID: 1, artistName: "Old Artist", trackName: "Old Name")
        let secondSong = Song.stub(trackID: 2, artistName: "Muse", trackName: "Uprising")
        let updatedVersion = Song.stub(trackID: 1, artistName: "New Artist", trackName: "New Name")

        try sut.saveRecentPlayed(song: firstVersion)
        try sut.saveRecentPlayed(song: secondSong)
        try sut.saveRecentPlayed(song: updatedVersion)

        let recentSongs = try sut.fetchRecentPlayed()

        #expect(recentSongs.count == 2)
        #expect(recentSongs.first?.trackID == 1)
        #expect(recentSongs.first?.artistName == "New Artist")
        #expect(recentSongs.first?.trackName == "New Name")
        #expect(recentSongs.last?.trackID == 2)
    }

    @Test
    func searchSongs_matchesTrack_artist_andCollectionNames() throws {
        let sut = try makeSUT()
        let firstSong = Song.stub(trackID: 1, artistName: "Dream Theater", collectionName: "Octavarium", trackName: "Panic Attack")
        let secondSong = Song.stub(trackID: 2, artistName: "Muse", collectionName: "Absolution", trackName: "Hysteria")

        try sut.save(song: firstSong)
        try sut.save(song: secondSong)

        #expect(try sut.searchSongs(term: "panic", limit: 10, offset: 0) == [firstSong])
        #expect(try sut.searchSongs(term: "muse", limit: 10, offset: 0) == [secondSong])
        #expect(try sut.searchSongs(term: "octavarium", limit: 10, offset: 0) == [firstSong])
    }

    @Test
    func searchSongs_appliesOffsetAndLimitAfterSorting() throws {
        let sut = try makeSUT()

        for trackID in 1...5 {
            try sut.save(song: .stub(trackID: trackID, artistName: "Muse", trackName: "Song \(trackID)"))
        }

        let pagedSongs = try sut.searchSongs(term: "muse", limit: 2, offset: 1)

        #expect(pagedSongs.map(\.trackID) == [4, 3])
    }

    @Test
    func save_keepsOnlyThe200MostRecentlySavedSongs() throws {
        let sut = try makeSUT()

        for trackID in 1...202 {
            try sut.save(song: .stub(trackID: trackID, trackName: "Song \(trackID)"))
        }

        let olderSongs = try sut.searchSongs(term: "Song 1", limit: 200, offset: 0)
        let newestSong = try sut.searchSongs(term: "Song 202", limit: 200, offset: 0)

        #expect(olderSongs.contains(where: { $0.trackID == 1 }) == false)
        #expect(olderSongs.contains(where: { $0.trackID == 2 }) == false)
        #expect(newestSong.map(\.trackID) == [202])
    }

    @Test
    func fetchRecentPlayed_returnsOnly10MostRecentlyPlayedSongs() throws {
        let sut = try makeSUT()

        for trackID in 1...12 {
            try sut.saveRecentPlayed(song: .stub(trackID: trackID, trackName: "Song \(trackID)"))
        }

        let recentSongs = try sut.fetchRecentPlayed()

        #expect(recentSongs.count == 10)
        #expect(recentSongs.map(\.trackID) == Array((3...12).reversed()))
    }

    private func makeSUT(
        maxStoredSongs: Int = 200,
        maxRecentPlayedSongs: Int = 10
    ) throws -> LocalStorageRepository {
        let schema = Schema([StoredSong.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let modelContext = ModelContext(container)

        return LocalStorageRepository(
            modelContext: modelContext,
            maxStoredSongs: maxStoredSongs,
            maxRecentPlayedSongs: maxRecentPlayedSongs
        )
    }
}
