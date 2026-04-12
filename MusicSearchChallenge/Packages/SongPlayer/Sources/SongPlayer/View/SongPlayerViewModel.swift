//
//  SongPlayerViewModel.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import Foundation
import Observation

@Observable
@MainActor
public final class SongPlayerViewModel {
    public let songs: [Song]
    public private(set) var currentIndex: Int
    public private(set) var currentTime: Double = 0
    public private(set) var duration: Double = 0
    public private(set) var isPlaying = false
    public var isRepeating = false

    @ObservationIgnored
    private let playbackController: SongPlaybackControlling
    @ObservationIgnored
    private var hasStartedPlayback = false
    @ObservationIgnored
    private let onSongChange: ((Song) -> Void)?
    
    private let timeFormatter: TimeFormatterProtocol

    public init(
        songs: [Song],
        startIndex: Int,
        onSongChange: ((Song) -> Void)? = nil,
        playbackController: SongPlaybackControlling = AVSongPlaybackController(),
        timeFormatter: TimeFormatterProtocol = TimeFormatter()
    ) {
        self.songs = songs
        self.currentIndex = songs.isEmpty ? 0 : min(max(startIndex, 0), songs.count - 1)
        self.onSongChange = onSongChange
        self.playbackController = playbackController
        self.timeFormatter = timeFormatter

        configurePlaybackCallbacks()
        sync(with: playbackController.snapshot)
        duration = songDuration
    }

    public var currentSong: Song? {
        guard songs.indices.contains(currentIndex) else { return nil }
        return songs[currentIndex]
    }

    public var trackName: String {
        currentSong?.trackName ?? ""
    }

    public var artistName: String {
        currentSong?.artistName ?? ""
    }

    public var albumName: String {
        currentSong?.collectionName ?? ""
    }

    public var artworkURL: URL? {
        currentSong?.artworkURL100
    }

    public var elapsedTimeText: String {
        timeFormatter.formatTime(currentTime)
    }

    public var remainingTimeText: String {
        "-" + timeFormatter.formatTime(max(duration - currentTime, 0))
    }

    public var canPlayNext: Bool {
        currentIndex < songs.count - 1
    }

    public func onAppear() {
        guard !hasStartedPlayback else { return }

        hasStartedPlayback = true
        loadCurrentSong(autoplay: true)
    }

    public func onDisappear() {
        playbackController.invalidate()
    }

    public func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    public func toggleRepeat() {
        isRepeating.toggle()
    }

    public func seek(to time: Double) {
        let clampedValue = max(0, min(time, duration))
        currentTime = clampedValue
        playbackController.seek(to: clampedValue)
    }

    public func playPrevious() {
        guard currentSong != nil else { return }

        if currentTime < 2, currentIndex > 0 {
            currentIndex -= 1
            notifySongChange()
            loadCurrentSong(autoplay: true)
            return
        }

        seek(to: 0)

        if isPlaying {
            playbackController.play()
        }
    }

    public func playNext() {
        guard canPlayNext else { return }

        currentIndex += 1
        notifySongChange()
        loadCurrentSong(autoplay: true)
    }

    public func play() {
        playbackController.play()
    }

    public func pause() {
        playbackController.pause()
    }

    private var songDuration: Double {
        Double(currentSong?.trackTimeMillis ?? 0) / 1000
    }

    private func configurePlaybackCallbacks() {
        playbackController.onSnapshotChange = { [weak self] snapshot in
            self?.sync(with: snapshot)
        }

        playbackController.onItemDidFinish = { [weak self] in
            self?.handlePlaybackFinished()
        }
    }

    private func sync(with snapshot: SongPlaybackSnapshot) {
        currentTime = max(snapshot.currentTime, 0)
        duration = snapshot.duration > 0 ? snapshot.duration : songDuration
        isPlaying = snapshot.isPlaying
    }

    private func loadCurrentSong(autoplay: Bool) {
        guard let song = currentSong else { return }

        currentTime = 0
        duration = Double(song.trackTimeMillis) / 1000
        playbackController.load(url: song.previewURL)

        if autoplay {
            playbackController.play()
        } else {
            playbackController.pause()
        }
    }

    private func handlePlaybackFinished() {
        if canPlayNext {
            currentIndex += 1
            notifySongChange()
            loadCurrentSong(autoplay: true)
            return
        }

        if isRepeating, !songs.isEmpty {
            currentIndex = 0
            notifySongChange()
            loadCurrentSong(autoplay: true)
            return
        }

        currentTime = 0
        isPlaying = false
        playbackController.pause()
        playbackController.seek(to: 0)
    }

    private func notifySongChange() {
        guard let currentSong else { return }
        onSongChange?(currentSong)
    }
}
