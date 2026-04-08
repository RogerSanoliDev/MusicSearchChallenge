//
//  AlbumResponseDTOTests.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 08/04/26.
//

import Foundation
import Testing
@testable import MusicSearchChallenge

struct AlbumResponseDTOTests {
    @Test
    @MainActor
    func decoding_filtersCollectionMetadata_andKeepsSongs() throws {
        let json = """
        {
          "results": [
            {
              "wrapperType": "collection",
              "collectionId": 42,
              "collectionName": "Album Only"
            },
            {
              "wrapperType": "track",
              "collectionId": 42,
              "trackId": 100,
              "artistName": "Artist",
              "collectionName": "Album Only",
              "trackName": "First Song",
              "previewUrl": "https://example.com/first.m4a",
              "artworkUrl30": "https://example.com/30.jpg",
              "artworkUrl60": "https://example.com/60.jpg",
              "artworkUrl100": "https://example.com/100.jpg",
              "trackTimeMillis": 123000,
              "isStreamable": true
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AlbumResponseDTO.self, from: json)

        #expect(response.songs.count == 1)
        #expect(response.songs.first?.trackId == 100)
    }

    @Test
    @MainActor
    func decoding_throwsForUnexpectedLookupPayload() {
        let json = """
        {
          "results": [
            {
              "wrapperType": "mystery"
            }
          ]
        }
        """.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(AlbumResponseDTO.self, from: json)
        }
    }
}
