//
//  AVSongPlaybackController.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import AVFoundation
import Foundation

@MainActor
public final class AVSongPlaybackController: SongPlaybackControlling {
    public var onSnapshotChange: ((SongPlaybackSnapshot) -> Void)?
    public var onItemDidFinish: (() -> Void)?

    public var snapshot: SongPlaybackSnapshot {
        SongPlaybackSnapshot(
            currentTime: currentTime,
            duration: duration,
            isPlaying: player.rate > 0
        )
    }

    private static let sharedPlayer: AVPlayerProtocol = AVPlayer()
    private let player: AVPlayerProtocol
    private var timeObserverToken: Any?
    private var endObserver: NSObjectProtocol?

    public init(player: AVPlayerProtocol? = nil) {
        self.player = player ?? Self.sharedPlayer
        configureObservers()
    }

    private func configureObservers() {
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.emitSnapshot()
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let item = notification.object as? AVPlayerItem

            Task { @MainActor [weak self] in
                guard let self else { return }
                guard let item, item == self.player.currentItem else { return }

                self.emitSnapshot()
                self.onItemDidFinish?()
            }
        }
    }

    public func invalidate() {
        if let timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    public func load(url: URL?) {
        if let url {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
        } else {
            player.replaceCurrentItem(with: nil)
        }

        emitSnapshot()
    }

    public func play() {
        player.play()
        emitSnapshot()
    }

    public func pause() {
        player.pause()
        emitSnapshot()
    }

    public func seek(to seconds: Double) {
        let clampedSeconds = max(0, seconds)
        let time = CMTime(seconds: clampedSeconds, preferredTimescale: 600)

        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.emitSnapshot()
            }
        }
    }

    private var currentTime: Double {
        max(player.currentTime().seconds, 0).isFinite ? max(player.currentTime().seconds, 0) : 0
    }

    private var duration: Double {
        guard let duration = player.currentItem?.duration.seconds, duration.isFinite else { return 0 }
        return max(duration, 0)
    }

    private func emitSnapshot() {
        onSnapshotChange?(snapshot)
    }
}
