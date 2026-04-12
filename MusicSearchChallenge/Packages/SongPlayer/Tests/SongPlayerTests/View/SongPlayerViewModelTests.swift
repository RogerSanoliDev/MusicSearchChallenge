import Foundation
import Networking
import Testing
@testable import SongPlayer

@MainActor
struct SongPlayerViewModelTests {
    @Test
    func onAppear_loadsStartSong_andStartsPlayback() {
        let playbackController = MockSongPlaybackController()
        let localFileCache = MockLocalFileCache()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under"), .stub(trackID: 2, trackName: "6:00", previewURL: URL(string: "https://example.com/preview.m4a"))],
            startIndex: 1,
            localFileCache: localFileCache,
            playbackController: playbackController
        )

        sut.onAppear()
        
        guard let expectedURL = URL(string: "https://example.com/preview.m4a") else {
            Issue.record("invalid expected URL")
            return
        }
        #expect(playbackController.loadedURLs == [expectedURL])
        #expect(localFileCache.requestedKeys == ["2"])
        #expect(playbackController.playCallCount == 1)
        #expect(sut.currentSong?.trackName == "6:00")
    }

    @Test
    func onAppear_prefersCachedLocalURL_whenAvailable() {
        let playbackController = MockSongPlaybackController()
        let localURL = URL(fileURLWithPath: "/tmp/cached-song.m4a")
        let localFileCache = MockLocalFileCache(cachedResolvedURL: localURL)
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 9, previewURL: URL(string: "https://example.com/preview.m4a"))],
            startIndex: 0,
            localFileCache: localFileCache,
            playbackController: playbackController
        )

        sut.onAppear()

        #expect(playbackController.loadedURLs == [localURL])
    }

    @Test
    func playPrevious_whenCurrentTimeLessThanTwoSeconds_andHasPrevious_loadsPreviousSong() {
        let playbackController = MockSongPlaybackController()
        let sut = SongPlayerViewModel(
            songs: [.stub(trackID: 1, trackName: "Pull Me Under"), .stub(trackID: 2, trackName: "6:00")],
            startIndex: 1,
            localFileCache: MockLocalFileCache(),
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
            localFileCache: MockLocalFileCache(),
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
            localFileCache: MockLocalFileCache(),
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
            localFileCache: MockLocalFileCache(),
            playbackController: playbackController
        )
        sut.onAppear()
        sut.toggleRepeat()

        playbackController.finishCurrentItem()

        #expect(sut.currentSong?.trackName == "Pull Me Under")
        #expect(playbackController.playCallCount == 2)
    }

    @Test
    func playNext_notifiesOnSongChangeWithNewCurrentSong() {
        let playbackController = MockSongPlaybackController()
        var changedSongs: [Song] = []
        let songs = [
            Song.stub(trackID: 1, trackName: "Pull Me Under"),
            Song.stub(trackID: 2, trackName: "6:00")
        ]
        let sut = SongPlayerViewModel(
            songs: songs,
            startIndex: 0,
            onSongChange: { changedSongs.append($0) },
            localFileCache: MockLocalFileCache(),
            playbackController: playbackController
        )

        sut.onAppear()
        sut.playNext()

        #expect(changedSongs == [songs[1]])
    }

    @Test
    func playbackFinished_notifiesOnSongChangeWhenAdvancingToNextSong() {
        let playbackController = MockSongPlaybackController()
        var changedSongs: [Song] = []
        let songs = [
            Song.stub(trackID: 1, trackName: "Pull Me Under"),
            Song.stub(trackID: 2, trackName: "6:00")
        ]
        let sut = SongPlayerViewModel(
            songs: songs,
            startIndex: 0,
            onSongChange: { changedSongs.append($0) },
            localFileCache: MockLocalFileCache(),
            playbackController: playbackController
        )

        sut.onAppear()
        playbackController.finishCurrentItem()

        #expect(changedSongs == [songs[1]])
        #expect(sut.currentSong?.trackName == "6:00")
    }
}
