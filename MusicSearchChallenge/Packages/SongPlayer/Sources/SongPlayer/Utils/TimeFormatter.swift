//
//  TimeFormatter.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

public protocol TimeFormatterProtocol {
    func formatTime(_ time: Double) -> String
}

public struct TimeFormatter: TimeFormatterProtocol {
    
    public init() {}
    
    public func formatTime(_ time: Double) -> String {
        let totalSeconds = max(Int(time.rounded(.down)), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
