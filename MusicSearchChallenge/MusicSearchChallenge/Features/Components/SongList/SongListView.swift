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
    private let showsLeadingSwipeAction: Bool
    private let onSongSelected: (Int) -> Void
    private let onLeadingSwipeAction: ((Song) -> Void)?
    private let onMoreOptionsSelected: ((Song) -> Void)?
    private let onReachedBottom: (() -> Void)?
    
    init(
        songs: [Song],
        sectionTitle: String? = nil,
        isPlaylist: Bool = false,
        showsPaginationLoader: Bool = true,
        onSongSelected: @escaping (Int) -> Void = { _ in },
        onLeadingSwipeAction: ((Song) -> Void)? = nil,
        onMoreOptionsSelected: ((Song) -> Void)? = nil,
        onReachedBottom: (() -> Void)? = nil
    ) {
        self.songs = songs
        self.sectionTitle = sectionTitle
        self.isPlaylist = isPlaylist
        self.showsPaginationLoader = showsPaginationLoader
        self.showsLeadingSwipeAction = onLeadingSwipeAction != nil
        self.onSongSelected = onSongSelected
        self.onLeadingSwipeAction = onLeadingSwipeAction
        self.onMoreOptionsSelected = onMoreOptionsSelected
        self.onReachedBottom = onReachedBottom
    }
    
    var body: some View {
        List {
            if let sectionTitle {
                Text(sectionTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            songRows
            
            if showsPaginationLoader && !isPlaylist {
                SongCellLoadingView()
                    .onAppear {
                        onReachedBottom?()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 0, for: .scrollContent)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var songRows: some View {
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
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if showsLeadingSwipeAction, let onLeadingSwipeAction {
                    Button(role: .destructive) {
                        onLeadingSwipeAction(song)
                    } label: {
                        Label("song_list.remove", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
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
