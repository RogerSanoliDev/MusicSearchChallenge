//
//  Song.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation

struct Song: Sendable, Equatable {
    let collectionID: Int
    let trackID: Int
    let artistName: String
    let collectionName: String
    let trackName: String
    let previewURL: URL?
    let artworkURL30: URL?
    let artworkURL60: URL?
    let artworkURL100: URL?
    let trackTimeMillis: Int
    let isStreamable: Bool

    nonisolated init(
        collectionID: Int,
        trackID: Int,
        artistName: String,
        collectionName: String,
        trackName: String,
        previewURL: URL?,
        artworkURL30: URL?,
        artworkURL60: URL?,
        artworkURL100: URL?,
        trackTimeMillis: Int,
        isStreamable: Bool
    ) {
        self.collectionID = collectionID
        self.trackID = trackID
        self.artistName = artistName
        self.collectionName = collectionName
        self.trackName = trackName
        self.previewURL = previewURL
        self.artworkURL30 = artworkURL30
        self.artworkURL60 = artworkURL60
        self.artworkURL100 = artworkURL100
        self.trackTimeMillis = trackTimeMillis
        self.isStreamable = isStreamable
    }

    nonisolated init(dto: SongDTO) {
        self.init(
            collectionID: dto.collectionId,
            trackID: dto.trackId,
            artistName: dto.artistName,
            collectionName: dto.collectionName,
            trackName: dto.trackName,
            previewURL: dto.previewUrl,
            artworkURL30: dto.artworkUrl30,
            artworkURL60: dto.artworkUrl60,
            artworkURL100: dto.artworkUrl100,
            trackTimeMillis: dto.trackTimeMillis,
            isStreamable: dto.isStreamable
        )
    }
}
