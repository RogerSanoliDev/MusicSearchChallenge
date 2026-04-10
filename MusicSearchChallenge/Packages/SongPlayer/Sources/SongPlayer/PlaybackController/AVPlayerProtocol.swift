//
//  AVPlayerProtocol.swift
//  SongPlayer
//
//  Created by Codex on 10/04/26.
//

import AVFoundation
import Foundation

public protocol AVPlayerProtocol: AnyObject {
    var rate: Float { get }
    var currentItem: AVPlayerItem? { get }

    func currentTime() -> CMTime
    func replaceCurrentItem(with playerItem: AVPlayerItem?)
    func play()
    func pause()
    func addPeriodicTimeObserver(
        forInterval interval: CMTime,
        queue: DispatchQueue?,
        using block: @escaping @Sendable (CMTime) -> Void
    ) -> Any
    func removeTimeObserver(_ observer: Any)
    func seek(
        to time: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        completionHandler: @escaping @Sendable (Bool) -> Void
    )
}

extension AVPlayer: AVPlayerProtocol {}
