//
//  AlbumView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 10/04/26.
//

import SwiftUI
import SongPlayer

struct AlbumView: View {
    @State private var viewModel: AlbumViewModel
    private let onSongSelected: (([Song], Int) -> Void)?

    init(
        song: Song,
        viewModel: AlbumViewModel? = nil,
        onSongSelected: (([Song], Int) -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel ?? AlbumViewModel(song: song))
        self.onSongSelected = onSongSelected
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(spacing: 0) {
                    headerView
                    SongListLoadingView()
                }
            case .success:
                VStack(spacing: 0) {
                    headerView
                    SongListView(
                        songs: viewModel.songs,
                        isPlaylist: true,
                        onSongSelected: { startIndex in
                            onSongSelected?(viewModel.songs, startIndex)
                        }
                    )
                }
            case .error:
                VStack(spacing: 0) {
                    headerView
                    InfoView(
                        systemImageName: "exclamationmark.triangle",
                        message: String(localized: "search.error.message")
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchAlbum()
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Thumbnail(
                url: viewModel.song.artworkURL100,
                size: 100,
                cornerRadius: 18,
                iconSize: 44
            )

            VStack(spacing: 6) {
                Text(viewModel.song.collectionName)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text(viewModel.song.artistName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }
}

#Preview {
    NavigationStack {
        AlbumView(
            song: Song(
                collectionID: 282703295,
                trackID: 282703309,
                artistName: "Dream Theater",
                collectionName: "Six Degrees of Inner Turbulence",
                trackName: "The Glass Prison",
                previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/26/8c/58/268c5897-4646-93a3-03f0-ebe230a94dbb/mzaf_8344343765306697585.plus.aac.p.m4a"),
                artworkURL30: nil,
                artworkURL60: nil,
                artworkURL100: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music/83/a6/95/mzi.zdmnatwf.jpg/100x100bb.jpg"),
                trackTimeMillis: 832760,
                isStreamable: true
            )
        )
    }
}
