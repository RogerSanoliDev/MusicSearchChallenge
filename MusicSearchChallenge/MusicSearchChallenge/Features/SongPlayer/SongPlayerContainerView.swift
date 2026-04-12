//
//  SongPlayerContainerView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import SwiftUI
import SongPlayer

struct SongPlayerContainerView: View {
    @State private var viewModel: SongPlayerContainerViewModel
    private let onMoreOptionsSelected: (Song) -> Void

    init(
        songs: [Song],
        startIndex: Int,
        onMoreOptionsSelected: @escaping (Song) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: SongPlayerContainerViewModel(
            songs: songs,
            startIndex: startIndex
        ))
        self.onMoreOptionsSelected = onMoreOptionsSelected
    }

    var body: some View {
        SongPlayerView(
            songs: viewModel.songs,
            startIndex: viewModel.startIndex,
            onSongChange: { song in
                Task {
                    await viewModel.handleSongChange(song)
                }
            }
        )
        .id(viewModel.playerViewID)
        .task {
            await viewModel.onAppear()
        }
        .toolbar {
            if let selectedSong = viewModel.selectedSong {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onMoreOptionsSelected(selectedSong)
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .accessibilityLabel(Text("More options"))
                }
            }
        }
    }
}

#Preview {
    SongPlayerContainerView(songs: [
        Song(
            collectionID: 1,
            trackID: 1,
            artistName: "Muse",
            collectionName: "Black Holes and Revelations",
            trackName: "Supermassive Black Hole",
            previewURL: nil,
            artworkURL30: nil,
            artworkURL60: nil,
            artworkURL100: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/4a/c1/5d/4ac15dc9-2ae6-1d5b-3add-43bae227f941/825646095452.jpg/100x100bb.jpg"),
            trackTimeMillis: 208852,
            isStreamable: true
        ),
        Song(
            collectionID: 2,
            trackID: 2,
            artistName: "Muse",
            collectionName: "The Resistance",
            trackName: "Uprising",
            previewURL: nil,
            artworkURL30: nil,
            artworkURL60: nil,
            artworkURL100: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/53/13/26/531326a2-b93d-9ab8-30cc-e4a9392e7b86/825646092666.jpg/100x100bb.jpg"),
            trackTimeMillis: 302827,
            isStreamable: true
        ),
    ], startIndex: 0)
}
