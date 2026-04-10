//
//  Song+DTO.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SongPlayer

extension Song {
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
