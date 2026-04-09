//
//  Song+stub.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import Foundation
@testable import MusicSearchChallenge

extension Song {
    static func stub(
        collectionID: Int = 99,
        trackID: Int = 1,
        artistName: String = "Artist",
        collectionName: String = "Album",
        trackName: String = "Track",
        previewURL: URL? = URL(string: "https://example.com/preview.m4a"),
        artworkURL30: URL? = URL(string: "https://example.com/30.jpg"),
        artworkURL60: URL? = URL(string: "https://example.com/60.jpg"),
        artworkURL100: URL? = URL(string: "https://example.com/100.jpg"),
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
