//
//  SongPlaybackControlling.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import Foundation

@MainActor
public protocol SongPlaybackControlling: AnyObject {
    var snapshot: SongPlaybackSnapshot { get }
    var onSnapshotChange: ((SongPlaybackSnapshot) -> Void)? { get set }
    var onItemDidFinish: (() -> Void)? { get set }

    func load(url: URL?)
    func play()
    func pause()
    func seek(to seconds: Double)
    func invalidate()
}
