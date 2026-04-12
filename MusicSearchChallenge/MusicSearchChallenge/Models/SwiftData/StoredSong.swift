//
//  StoredSong.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import Foundation
import SwiftData
import SongPlayer

@Model
final class StoredSong {
    @Attribute(.unique) var trackID: Int
    var collectionID: Int
    var artistName: String
    var collectionName: String
    var trackName: String
    var previewURL: URL?
    var artworkURL30: URL?
    var artworkURL60: URL?
    var artworkURL100: URL?
    var trackTimeMillis: Int
    var isStreamable: Bool
    var savedAt: Date
    var lastPlayedAt: Date?

    init(song: Song, savedAt: Date = .now, lastPlayedAt: Date? = nil) {
        self.trackID = song.trackID
        self.collectionID = song.collectionID
        self.artistName = song.artistName
        self.collectionName = song.collectionName
        self.trackName = song.trackName
        self.previewURL = song.previewURL
        self.artworkURL30 = song.artworkURL30
        self.artworkURL60 = song.artworkURL60
        self.artworkURL100 = song.artworkURL100
        self.trackTimeMillis = song.trackTimeMillis
        self.isStreamable = song.isStreamable
        self.savedAt = savedAt
        self.lastPlayedAt = lastPlayedAt
    }

    func updateFromSearch(song: Song, savedAt: Date = .now) {
        updateSongFields(from: song)
        self.savedAt = savedAt
    }

    func updateFromRecentPlayed(song: Song, savedAt: Date = .now, lastPlayedAt: Date = .now) {
        updateSongFields(from: song)
        self.savedAt = savedAt
        self.lastPlayedAt = lastPlayedAt
    }

    var song: Song {
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

    private func updateSongFields(from song: Song) {
        collectionID = song.collectionID
        artistName = song.artistName
        collectionName = song.collectionName
        trackName = song.trackName
        previewURL = song.previewURL
        artworkURL30 = song.artworkURL30
        artworkURL60 = song.artworkURL60
        artworkURL100 = song.artworkURL100
        trackTimeMillis = song.trackTimeMillis
        isStreamable = song.isStreamable
    }
}
