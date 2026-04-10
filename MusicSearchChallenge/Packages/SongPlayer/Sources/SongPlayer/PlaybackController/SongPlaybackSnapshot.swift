//
//  SongPlaybackSnapshot.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

public struct SongPlaybackSnapshot: Equatable, Sendable {
    public var currentTime: Double
    public var duration: Double
    public var isPlaying: Bool

    public init(currentTime: Double = 0, duration: Double = 0, isPlaying: Bool = false) {
        self.currentTime = currentTime
        self.duration = duration
        self.isPlaying = isPlaying
    }
}
