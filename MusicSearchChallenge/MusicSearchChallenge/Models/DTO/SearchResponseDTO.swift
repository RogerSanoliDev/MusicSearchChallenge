//
//  SearchResponseDTO.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

struct SearchResponseDTO: Decodable, Sendable {
    let results: [SongDTO]

    private enum CodingKeys: String, CodingKey {
        case results
    }

    nonisolated init(results: [SongDTO]) {
        self.results = results
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([SongDTO].self, forKey: .results)
    }
}
