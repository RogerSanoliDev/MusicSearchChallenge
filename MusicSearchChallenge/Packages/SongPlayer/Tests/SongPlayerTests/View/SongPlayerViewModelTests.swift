import Foundation
import Testing
@testable import SongPlayer

@MainActor
struct SongPlayerViewModelTests {
    @Test
    func onAppear_loadsStartSong_andStartsPlayback() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under"), .stub(trackID: 2, trackName: "6:00", previewURL: URL(string: "https://example.com/preview.m4a"))],
            startIndex: 1,
            playbackController: playbackController
        )

        sut.onAppear()
        
        guard let expectedURL = URL(string: "https://example.com/preview.m4a") else {
            Issue.record("invalid expected URL")
            return
        }
        #expect(playbackController.loadedURLs == [expectedURL])
        #expect(playbackController.playCallCount == 1)
        #expect(sut.currentSong?.trackName == "6:00")
    }

    @Test
    func playPrevious_whenCurrentTimeLessThanTwoSeconds_andHasPrevious_loadsPreviousSong() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under"), .stub(trackID: 2, trackName: "6:00")],
            startIndex: 1,
            playbackController: playbackController
        )
        sut.onAppear()
        playbackController.emitSnapshot(.init(currentTime: 1, duration: 180, isPlaying: true))

        sut.playPrevious()

        #expect(sut.currentSong?.trackName == "Pull Me Under")
        #expect(playbackController.playCallCount == 2)
    }

    @Test
    func playPrevious_whenCurrentTimeIsGreaterThanTwoSeconds_restartsCurrentSong() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under")],
            startIndex: 0,
            playbackController: playbackController
        )
        sut.onAppear()
        playbackController.emitSnapshot(.init(currentTime: 5, duration: 180, isPlaying: true))

        sut.playPrevious()

        #expect(playbackController.seekTargets.last == 0)
        #expect(sut.currentSong?.trackName == "Pull Me Under")
    }

    @Test
    func playNext_whenThereIsNoNextSong_doesNothing() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under")],
            startIndex: 0,
            playbackController: playbackController
        )
        sut.onAppear()

        sut.playNext()

        #expect(playbackController.loadedURLs.count == 1)
        #expect(sut.currentSong?.trackName == "Pull Me Under")
    }

    @Test
    func playbackFinished_withRepeatEnabled_loopsBackToFirstSong() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under"), .stub(trackID: 2, trackName: "6:00")],
            startIndex: 1,
            playbackController: playbackController
        )
        sut.onAppear()
        sut.toggleRepeat()

        playbackController.finishCurrentItem()

        #expect(sut.currentSong?.trackName == "Pull Me Under")
        #expect(playbackController.playCallCount == 2)
    }
}
