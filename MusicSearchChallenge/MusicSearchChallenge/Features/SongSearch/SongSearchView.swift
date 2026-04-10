//
//  SongSearchView.swift
//  MusicSearchChallenge
//
//  Created by Roger dos Santos Oliveira on 06/04/26.
//

import SwiftUI
import SongPlayer

struct SongSearchView: View {
    @State private var viewModel = SongSearchViewModel()
    private let onSongSelected: (Song) -> Void
    private let onMoreOptionsSelected: (Song) -> Void

    init(
        viewModel: SongSearchViewModel = SongSearchViewModel(),
        onSongSelected: @escaping (Song) -> Void = { _ in },
        onMoreOptionsSelected: @escaping (Song) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSongSelected = onSongSelected
        self.onMoreOptionsSelected = onMoreOptionsSelected
    }

    var body: some View {
        contentView
            .preferredColorScheme(.dark)
            .navigationTitle(Text("search.title"))
            .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Text("search.field.placeholder")
        )
        .accessibilityLabel(Text("search.screen.voiceover"))
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            InfoView(
                systemImageName: "magnifyingglass",
                message: String(localized: "search.idle.message")
            )
        case .recent:
            Text("recent")
        case .loading:
            SongListLoadingView()
        case .success:
            SongListView(
                songs: viewModel.songs,
                onSongSelected: { index in
                    onSongSelected(viewModel.songs[index])
                },
                onMoreOptionsSelected: onMoreOptionsSelected
            )
        case .error:
            InfoView(
                systemImageName: "exclamationmark.triangle",
                message: String(localized: "search.error.message")
            )
        case .empty:
            InfoView(
                systemImageName: "music.note.list",
                message: String.localizedStringWithFormat(
                    NSLocalizedString("search.empty.message", comment: "Message shown when no songs match the search query"),
                    viewModel.searchText
                )
            )
        }
    }
}

#Preview {
    SongSearchView()
}
