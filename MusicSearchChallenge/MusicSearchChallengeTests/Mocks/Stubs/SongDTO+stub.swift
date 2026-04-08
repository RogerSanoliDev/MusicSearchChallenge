//
//  SongDTO+stub.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation
@testable import MusicSearchChallenge

extension SongDTO {
    static func stub(
        collectionId: Int = 99,
        trackId: Int = 1,
        artistName: String = "Artist",
        collectionName: String = "Album",
        trackName: String = "Track",
        previewUrl: URL? = URL(string: "https://example.com/preview.m4a"),
        artworkUrl30: URL? = URL(string: "https://example.com/30.jpg"),
        artworkUrl60: URL? = URL(string: "https://example.com/60.jpg"),
        artworkUrl100: URL? = URL(string: "https://example.com/100.jpg"),
        trackTimeMillis: Int = 180_000,
        isStreamable: Bool = true
    ) -> SongDTO {
        SongDTO(
            collectionId: collectionId,
            trackId: trackId,
            artistName: artistName,
            collectionName: collectionName,
            trackName: trackName,
            previewUrl: previewUrl,
            artworkUrl30: artworkUrl30,
            artworkUrl60: artworkUrl60,
            artworkUrl100: artworkUrl100,
            trackTimeMillis: trackTimeMillis,
            isStreamable: isStreamable
        )
    }
}
