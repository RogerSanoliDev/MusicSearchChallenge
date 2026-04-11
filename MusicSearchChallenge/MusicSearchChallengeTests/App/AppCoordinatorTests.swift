//
//  AppCoordinatorTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 11/04/26.
//

import Testing
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
struct AppCoordinatorTests {
    @Test
    func init_setsSongSearchAsRoot_andStartsWithoutNavigationState() {
        let sut = AppCoordinator()

        #expect(sut.rootPage == .songSearch)
        #expect(sut.path.isEmpty)
        #expect(sut.sheet == nil)
    }

    @Test
    func showSongPlayer_withSingleSong_appendsSongPlayerPage() throws {
        let sut = AppCoordinator()
        let song = Song.stub(trackID: 10, trackName: "Pull Me Under")

        sut.showSongPlayer(song: song)

        #expect(sut.path.count == 1)

        let page = try #require(sut.path.first)
        guard case .songPlayer(let context) = page else {
            Issue.record("Expected a song player page")
            return
        }

        #expect(context.songs == [song])
        #expect(context.startIndex == 0)
    }

    @Test
    func showMoreOptions_setsSheetToSelectedSong() {
        let sut = AppCoordinator()
        let song = Song.stub(trackID: 11, trackName: "The Glass Prison")

        sut.showMoreOptions(for: song)

        #expect(sut.sheet == .moreOptions(song))
    }

    @Test
    func viewAlbum_closesSheet_andPushesAlbumPage() {
        let sut = AppCoordinator()
        let song = Song.stub(collectionID: 77, trackID: 12)

        sut.showMoreOptions(for: song)
        sut.viewAlbum(from: song)

        #expect(sut.sheet == nil)
        #expect(sut.path == [.album(song)])
    }

    @Test
    func playAlbum_withoutExistingPlayer_appendsNewSongPlayerPage() throws {
        let sut = AppCoordinator()
        let songs = [
            Song.stub(trackID: 1, trackName: "Track 1"),
            Song.stub(trackID: 2, trackName: "Track 2"),
        ]

        sut.playAlbum(songs: songs, startIndex: 1)

        #expect(sut.path.count == 1)

        let page = try #require(sut.path.first)
        guard case .songPlayer(let context) = page else {
            Issue.record("Expected a song player page")
            return
        }

        #expect(context.songs == songs)
        #expect(context.startIndex == 1)
    }

    @Test
    func playAlbum_withExistingPlayer_replacesPlayerAndRemovesPagesAboveIt() throws {
        let sut = AppCoordinator()
        let originalSong = Song.stub(trackID: 20, trackName: "Original")
        let albumSong = Song.stub(collectionID: 99, trackID: 21, trackName: "Album Seed")
        let updatedSongs = [
            Song.stub(collectionID: 99, trackID: 30, trackName: "New Track 1"),
            Song.stub(collectionID: 99, trackID: 31, trackName: "New Track 2"),
        ]

        sut.showSongPlayer(song: originalSong)
        sut.showAlbum(for: albumSong)

        sut.playAlbum(songs: updatedSongs, startIndex: 1)

        #expect(sut.path.count == 1)

        let page = try #require(sut.path.first)
        guard case .songPlayer(let context) = page else {
            Issue.record("Expected a song player page")
            return
        }

        #expect(context.songs == updatedSongs)
        #expect(context.startIndex == 1)
    }
}
