//
//  AlbumViewModelTests.swift
//  MusicSearchChallenge
//
//  Created by Codex on 10/04/26.
//

import Foundation
import Testing
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
struct AlbumViewModelTests {
    @Test
    func init_setsLoadingState_andKeepsProvidedSong() {
        let song = Song.stub(collectionID: 42, artistName: "Daft Punk", collectionName: "Discovery")

        let sut = AlbumViewModel(song: song)

        #expect(sut.song.collectionID == 42)
        #expect(sut.song.collectionName == "Discovery")
        #expect(sut.song.artistName == "Daft Punk")
        #expect(sut.state == .loading)
        #expect(sut.songs.isEmpty)
    }

    @Test
    func fetchAlbum_loadsSongsForCollection_andUpdatesSuccessState() async {
        let mock = SearchServiceMock()
        let song = Song.stub(collectionID: 42, artistName: "Daft Punk", collectionName: "Discovery")

        await mock.setFetchAlbumHandler { collectionId in
            #expect(collectionId == 42)

            return [
                .stub(collectionID: 42, trackID: 1, artistName: "Daft Punk", collectionName: "Discovery", trackName: "One More Time"),
                .stub(collectionID: 42, trackID: 2, artistName: "Daft Punk", collectionName: "Discovery", trackName: "Aerodynamic"),
            ]
        }

        let sut = AlbumViewModel(song: song, searchService: mock)

        await sut.fetchAlbum()

        #expect(await mock.fetchAlbumCalls == [.init(collectionId: 42)])
        #expect(sut.state == .success)
        #expect(sut.songs.map(\.trackName) == ["One More Time", "Aerodynamic"])
    }

    @Test
    func fetchAlbum_withEmptyResults_setsEmptyState() async {
        let mock = SearchServiceMock()
        let song = Song.stub(collectionID: 7)

        await mock.setFetchAlbumHandler { _ in [] }

        let sut = AlbumViewModel(song: song, searchService: mock)

        await sut.fetchAlbum()

        #expect(sut.state == .empty)
        #expect(sut.songs.isEmpty)
    }

    @Test
    func fetchAlbum_whenServiceFails_setsErrorState() async {
        enum AlbumError: Error {
            case failed
        }

        let mock = SearchServiceMock()
        let song = Song.stub(collectionID: 99)

        await mock.setFetchAlbumHandler { _ in
            throw AlbumError.failed
        }

        let sut = AlbumViewModel(song: song, searchService: mock)

        await sut.fetchAlbum()

        #expect(sut.state == .error)
        #expect(sut.songs.isEmpty)
    }

    @Test
    func fetchAlbum_whenCalledTwice_onlyLoadsOnce() async {
        let mock = SearchServiceMock()
        let song = Song.stub(collectionID: 55)

        await mock.setFetchAlbumHandler { _ in
            [.stub(collectionID: 55, trackID: 1, trackName: "Track 1")]
        }

        let sut = AlbumViewModel(song: song, searchService: mock)

        await sut.fetchAlbum()
        await sut.fetchAlbum()

        #expect(await mock.fetchAlbumCalls == [.init(collectionId: 55)])
        #expect(sut.state == .success)
    }
}
