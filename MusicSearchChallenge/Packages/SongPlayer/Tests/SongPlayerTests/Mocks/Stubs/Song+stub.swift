//
//  Song+stub.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import SongPlayer
import Foundation

extension Song {
    static func stub(
        collectionID: Int = 282703295,
        trackID: Int = 282703309,
        artistName: String = "Dream Theater",
        collectionName: String = "Six Degrees of Inner Turbulence",
        trackName: String = "The Glass Prison",
        previewURL: URL? = URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/26/8c/58/268c5897-4646-93a3-03f0-ebe230a94dbb/mzaf_8344343765306697585.plus.aac.p.m4a"),
        artworkURL30: URL? = nil,
        artworkURL60: URL? = nil,
        artworkURL100: URL? = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music/83/a6/95/mzi.zdmnatwf.jpg/100x100bb.jpg"),
        trackTimeMillis: Int = 180_000,
        isStreamable: Bool = true
    ) -> Song {
        Song(
            collectionID: collectionID,
            trackID: trackID,
            artistName: artistName,
            collectionName: collectionName,
            trackName: trackName,
            previewURL: previewURL,
            artworkURL30: artworkURL30,
            artworkURL60: artworkURL60,
            artworkURL100: artworkURL100,
            trackTimeMillis: trackTimeMillis,
            isStreamable: isStreamable
        )
    }
}
