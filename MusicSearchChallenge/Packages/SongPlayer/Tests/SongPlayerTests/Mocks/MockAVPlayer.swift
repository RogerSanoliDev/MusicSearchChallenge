//
//  MockAVPlayer.swift
//  SongPlayer
//
//  Created by Codex on 10/04/26.
//

import AVFoundation
@testable import SongPlayer

final class MockAVPlayer: AVPlayerProtocol {
    var rate: Float = 0
    var currentItem: AVPlayerItem?
    var currentTimeValue: CMTime = .zero
    var periodicObserverToken: Any = UUID()
    var removedTimeObserver: Any?
    var replacedPlayerItem: AVPlayerItem?
    var playCallCount = 0
    var pauseCallCount = 0
    var seekTimes: [CMTime] = []
    var periodicObserver: (@Sendable (CMTime) -> Void)?

    func currentTime() -> CMTime {
        currentTimeValue
    }

    func replaceCurrentItem(with playerItem: AVPlayerItem?) {
        replacedPlayerItem = playerItem
        currentItem = playerItem
    }

    func play() {
        playCallCount += 1
        rate = 1
    }

    func pause() {
        pauseCallCount += 1
        rate = 0
    }

    func addPeriodicTimeObserver(
        forInterval interval: CMTime,
        queue: DispatchQueue?,
        using block: @escaping @Sendable (CMTime) -> Void
    ) -> Any {
        periodicObserver = block
        return periodicObserverToken
    }

    func removeTimeObserver(_ observer: Any) {
        removedTimeObserver = observer
    }

    func seek(
        to time: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
        seekTimes.append(time)
        currentTimeValue = time
        completionHandler(true)
    }

    func emitPeriodicTime() {
        periodicObserver?(currentTimeValue)
    }
}
