//
//  AlbumResponseDTO.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

struct AlbumResponseDTO: Decodable, Sendable {
    let songs: [SongDTO]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
    
    nonisolated init(songs: [SongDTO]) {
        self.songs = songs
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let results = try container.decode([LookupResultDTO].self, forKey: .results)
        self.songs = results.compactMap(\.song)
    }
}

fileprivate enum LookupResultDTO: Decodable, Sendable {
    case song(SongDTO)
    case collection

    nonisolated var song: SongDTO? {
        guard case .song(let song) = self else { return nil }
        return song
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.trackId) {
            self = .song(try SongDTO(from: decoder))
            return
        }

        if container.contains(.collectionId) {
            self = .collection
            return
        }

        throw DecodingError.dataCorruptedError(
            forKey: .collectionId,
            in: container,
            debugDescription: "Unexpected lookup result payload."
        )
    }

    private enum CodingKeys: String, CodingKey {
        case collectionId
        case trackId
    }
}
