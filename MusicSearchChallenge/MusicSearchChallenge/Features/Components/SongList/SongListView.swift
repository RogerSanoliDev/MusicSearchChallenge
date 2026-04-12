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
    private let sectionTitle: String?
    private let isPlaylist: Bool
    private let showsPaginationLoader: Bool
    private let onSongSelected: (Int) -> Void
    private let onMoreOptionsSelected: ((Song) -> Void)?
    private let onReachedBottom: (() -> Void)?
    
    init(
        songs: [Song],
        sectionTitle: String? = nil,
        isPlaylist: Bool = false,
        showsPaginationLoader: Bool = true,
        onSongSelected: @escaping (Int) -> Void = { _ in },
        onMoreOptionsSelected: ((Song) -> Void)? = nil,
        onReachedBottom: (() -> Void)? = nil
    ) {
        self.songs = songs
        self.sectionTitle = sectionTitle
        self.isPlaylist = isPlaylist
        self.showsPaginationLoader = showsPaginationLoader
        self.onSongSelected = onSongSelected
        self.onMoreOptionsSelected = onMoreOptionsSelected
        self.onReachedBottom = onReachedBottom
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let sectionTitle {
                    Text(sectionTitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                }

                ForEach(Array(songs.enumerated()), id: \.element.trackID) { index, song in
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                if showsPaginationLoader && !isPlaylist {
                    SongCellLoadingView()
                        .onAppear {
                            onReachedBottom?()
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
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
