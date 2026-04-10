//
//  SongListView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SwiftUI
import SongPlayer

struct SongListView: View {
    let songs: [Song]
    private let isPlaylist: Bool
    private let onSongSelected: (Int) -> Void
    private let onMoreOptionsSelected: ((Song) -> Void)?

    init(
        songs: [Song],
        isPlaylist: Bool = false,
        onSongSelected: @escaping (Int) -> Void = { _ in },
        onMoreOptionsSelected: ((Song) -> Void)? = nil
    ) {
        self.songs = songs
        self.isPlaylist = isPlaylist
        self.onSongSelected = onSongSelected
        self.onMoreOptionsSelected = onMoreOptionsSelected
    }

    var body: some View {
        List(Array(songs.enumerated()), id: \.element.trackID) { index, song in
            SongCell(
                song: song,
                showsMoreOptionsButton: !isPlaylist,
                onMoreOptionsTap: {
                    onMoreOptionsSelected?(song)
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onSongSelected(index)
            }
            .listRowSeparator(.hidden)
        }
        .preferredColorScheme(.dark)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SongListView(
        songs: [
            Song(
                collectionID: 1,
                trackID: 1,
                artistName: "Queen",
                collectionName: "A Night at the Opera",
                trackName: "Bohemian Rhapsody",
                previewURL: nil,
                artworkURL30: nil,
                artworkURL60: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/2a/94/14/2a941457-2ad0-1748-4ce1-52e8a61ac778/source/60x60bb.jpg"),
                artworkURL100: nil,
                trackTimeMillis: 354000,
                isStreamable: true
            ),
            Song(
                collectionID: 2,
                trackID: 2,
                artistName: "The Beatles",
                collectionName: "Abbey Road",
                trackName: "Come Together",
                previewURL: nil,
                artworkURL30: nil,
                artworkURL60: nil,
                artworkURL100: nil,
                trackTimeMillis: 259000,
                isStreamable: true
            ),
        ]
    )
}
