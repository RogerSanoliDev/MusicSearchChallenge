//
//  SongDTO.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation

struct SongDTO: Decodable, Sendable {
    let collectionId: Int
    let trackId: Int
    let artistName: String
    let collectionName: String
    let trackName: String
    let previewUrl: URL?
    let artworkUrl30: URL?
    let artworkUrl60: URL?
    let artworkUrl100: URL?
    let trackTimeMillis: Int
    let isStreamable: Bool

    private enum CodingKeys: String, CodingKey {
        case collectionId
        case trackId
        case artistName
        case collectionName
        case trackName
        case previewUrl
        case artworkUrl30
        case artworkUrl60
        case artworkUrl100
        case trackTimeMillis
        case isStreamable
    }

    nonisolated init(
        collectionId: Int,
        trackId: Int,
        artistName: String,
        collectionName: String,
        trackName: String,
        previewUrl: URL?,
        artworkUrl30: URL?,
        artworkUrl60: URL?,
        artworkUrl100: URL?,
        trackTimeMillis: Int,
        isStreamable: Bool
    ) {
        self.collectionId = collectionId
        self.trackId = trackId
        self.artistName = artistName
        self.collectionName = collectionName
        self.trackName = trackName
        self.previewUrl = previewUrl
        self.artworkUrl30 = artworkUrl30
        self.artworkUrl60 = artworkUrl60
        self.artworkUrl100 = artworkUrl100
        self.trackTimeMillis = trackTimeMillis
        self.isStreamable = isStreamable
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.collectionId = try container.decode(Int.self, forKey: .collectionId)
        self.trackId = try container.decode(Int.self, forKey: .trackId)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.collectionName = try container.decode(String.self, forKey: .collectionName)
        self.trackName = try container.decode(String.self, forKey: .trackName)
        self.previewUrl = try container.decodeIfPresent(URL.self, forKey: .previewUrl)
        self.artworkUrl30 = try container.decodeIfPresent(URL.self, forKey: .artworkUrl30)
        self.artworkUrl60 = try container.decodeIfPresent(URL.self, forKey: .artworkUrl60)
        self.artworkUrl100 = try container.decodeIfPresent(URL.self, forKey: .artworkUrl100)
        self.trackTimeMillis = try container.decode(Int.self, forKey: .trackTimeMillis)
        self.isStreamable = try container.decode(Bool.self, forKey: .isStreamable)
    }
}
