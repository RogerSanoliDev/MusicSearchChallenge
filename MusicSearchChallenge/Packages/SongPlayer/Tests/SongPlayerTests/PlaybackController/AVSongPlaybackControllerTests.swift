//
//  AVSongPlaybackControllerTests.swift
//  SongPlayer
//
//  Created by Codex on 10/04/26.
//

import AVFoundation
import Foundation
import Testing
@testable import SongPlayer

@MainActor
struct AVSongPlaybackControllerTests {
    @Test
    func load_withURL_replacesCurrentItem() {
        let player = MockAVPlayer()
        let sut = AVSongPlaybackController(player: player)
        let url = URL(string: "https://example.com/preview.m4a")

        sut.load(url: url)

        #expect(player.replacedPlayerItem?.asset as? AVURLAsset != nil)
        #expect((player.replacedPlayerItem?.asset as? AVURLAsset)?.url == url)
    }

    @Test
    func play_updatesPlayerAndSnapshot() {
        let player = MockAVPlayer()
        let sut = AVSongPlaybackController(player: player)
        var receivedSnapshot: SongPlaybackSnapshot?
        sut.onSnapshotChange = { receivedSnapshot = $0 }

        sut.play()

        #expect(player.playCallCount == 1)
        #expect(receivedSnapshot?.isPlaying == true)
    }

    @Test
    func pause_updatesPlayerAndSnapshot() {
        let player = MockAVPlayer()
        player.rate = 1
        let sut = AVSongPlaybackController(player: player)
        var receivedSnapshot: SongPlaybackSnapshot?
        sut.onSnapshotChange = { receivedSnapshot = $0 }

        sut.pause()

        #expect(player.pauseCallCount == 1)
        #expect(receivedSnapshot?.isPlaying == false)
    }

    @Test
    func seek_clampsNegativeTimeToZero() {
        let player = MockAVPlayer()
        let sut = AVSongPlaybackController(player: player)

        sut.seek(to: -5)

        #expect(player.seekTimes.last?.seconds == 0)
    }

    @Test
    func periodicObserver_emitsUpdatedSnapshot() async {
        let player = MockAVPlayer()
        player.currentTimeValue = CMTime(seconds: 44, preferredTimescale: 600)
        player.currentItem = AVPlayerItem(url: URL(string: "https://example.com/preview.m4a")!)
        let sut = AVSongPlaybackController(player: player)
        var receivedSnapshot: SongPlaybackSnapshot?
        sut.onSnapshotChange = { receivedSnapshot = $0 }

        player.emitPeriodicTime()
        await Task.yield()

        #expect(receivedSnapshot?.currentTime == 44)
    }

    @Test
    func invalidate_removesTimeObserver() {
        let player = MockAVPlayer()
        let sut = AVSongPlaybackController(player: player)

        sut.invalidate()

        #expect(player.removedTimeObserver != nil)
    }
}
