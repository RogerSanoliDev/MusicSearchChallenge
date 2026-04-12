//
//  SongPlayerContainerViewModelTests.swift
//  MusicSearchChallengeTests
//
//  Created by Codex on 12/04/26.
//

import Testing
import SongPlayer
@testable import MusicSearchChallenge

@MainActor
struct SongPlayerContainerViewModelTests {
    @Test
    func playerViewID_combinesTrackIDsAndStartIndex() {
        let sut = SongPlayerContainerViewModel(
            songs: [
                .stub(trackID: 10),
                .stub(trackID: 20),
                .stub(trackID: 30)
            ],
            startIndex: 1
        )

        #expect(sut.playerViewID == "10-20-30-1")
    }

    @Test
    func selectedSong_returnsSongAtStartIndex() {
        let expectedSong = Song.stub(trackID: 20, trackName: "Uprising")
        let sut = SongPlayerContainerViewModel(
            songs: [
                .stub(trackID: 10, trackName: "Starlight"),
                expectedSong
            ],
            startIndex: 1
        )

        #expect(sut.selectedSong == expectedSong)
    }

    @Test
    func selectedSong_whenStartIndexIsOutOfBounds_returnsFirstSong() {
        let firstSong = Song.stub(trackID: 10, trackName: "Starlight")
        let sut = SongPlayerContainerViewModel(
            songs: [
                firstSong,
                .stub(trackID: 20, trackName: "Uprising")
            ],
            startIndex: 99
        )

        #expect(sut.selectedSong == firstSong)
    }

    @Test
    func selectedSong_whenSongsAreEmpty_returnsNil() {
        let sut = SongPlayerContainerViewModel(
            songs: [],
            startIndex: 0
        )

        #expect(sut.selectedSong == nil)
    }

    @Test
    func onAppear_savesCurrentSongAsRecentPlayed() async {
        let mock = SearchServiceMock()
        let song = Song.stub(trackID: 42, trackName: "Hysteria")
        let sut = SongPlayerContainerViewModel(
            songs: [song],
            startIndex: 0,
            searchService: mock
        )

        await sut.onAppear()

        #expect(await mock.saveRecentPlayedCalls == [.init(song: song)])
    }

    @Test
    func handleSongChange_updatesCurrentSong_andSavesItAsRecentPlayed() async {
        let mock = SearchServiceMock()
        let firstSong = Song.stub(trackID: 10, trackName: "Starlight")
        let secondSong = Song.stub(trackID: 20, trackName: "Uprising")
        let sut = SongPlayerContainerViewModel(
            songs: [firstSong, secondSong],
            startIndex: 0,
            searchService: mock
        )

        await sut.handleSongChange(secondSong)

        #expect(sut.currentSong == secondSong)
        #expect(sut.selectedSong == secondSong)
        #expect(await mock.saveRecentPlayedCalls == [.init(song: secondSong)])
    }
}
