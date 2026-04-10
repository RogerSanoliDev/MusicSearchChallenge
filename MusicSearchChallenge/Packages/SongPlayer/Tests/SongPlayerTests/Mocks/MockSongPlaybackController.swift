//
//  MockSongPlaybackController.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import Foundation
import SongPlayer

@MainActor
final class MockSongPlaybackController: SongPlaybackControlling {
    var snapshot = SongPlaybackSnapshot()
    var onSnapshotChange: ((SongPlaybackSnapshot) -> Void)?
    var onItemDidFinish: (() -> Void)?

    var loadedURLs: [URL] = []
    var playCallCount = 0
    var pauseCallCount = 0
    var seekTargets: [Double] = []

    func load(url: URL?) {
        if let url {
            loadedURLs.append(url)
        }
    }

    func play() {
        playCallCount += 1
        snapshot.isPlaying = true
        onSnapshotChange?(snapshot)
    }

    func pause() {
        pauseCallCount += 1
        snapshot.isPlaying = false
        onSnapshotChange?(snapshot)
    }

    func seek(to seconds: Double) {
        seekTargets.append(seconds)
        snapshot.currentTime = seconds
        onSnapshotChange?(snapshot)
    }

    func invalidate() {
        onSnapshotChange = nil
        onItemDidFinish = nil
    }

    func emitSnapshot(_ snapshot: SongPlaybackSnapshot) {
        self.snapshot = snapshot
        onSnapshotChange?(snapshot)
    }

    func finishCurrentItem() {
        onItemDidFinish?()
    }
}
