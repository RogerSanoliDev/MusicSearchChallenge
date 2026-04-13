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
            .navigationTitle(Text("search.title"))
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.handleViewAppear()
            }
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("search.field.placeholder")
            )
            .refreshable {
                await viewModel.reloadSearch()
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.state)
            .accessibilityLabel(Text("search.screen.voiceover"))
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            InfoView(
                systemImageName: "magnifyingglass",
                message: String(localized: "search.idle.message")
            )
        case .recentPlayed:
            SongListView(
                songs: viewModel.recentPlayedSongs,
                sectionTitle: String(localized: "recent_played.title"),
                showsPaginationLoader: false,
                onSongSelected: { index in
                    guard let song = viewModel.currentSong(at: index) else { return }
                    onSongSelected(song)
                },
                onLeadingSwipeAction: { song in
                    Task {
                        await viewModel.removeRecentPlayed(song)
                    }
                },
                onMoreOptionsSelected: onMoreOptionsSelected
            )
        case .loading:
            SongListLoadingView()
        case .success:
            SongListView(
                songs: viewModel.songs,
                showsPaginationLoader: viewModel.hasMorePages,
                onSongSelected: { index in
                    guard let song = viewModel.currentSong(at: index) else { return }
                    onSongSelected(song)
                },
                onMoreOptionsSelected: onMoreOptionsSelected,
                onReachedBottom: {
                    viewModel.loadNextPageIfNeeded()
                }
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
