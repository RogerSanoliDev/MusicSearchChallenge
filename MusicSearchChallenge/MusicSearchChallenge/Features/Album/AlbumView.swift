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

    init(song: Song, viewModel: AlbumViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? AlbumViewModel(song: song))
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
                    SongListView(songs: viewModel.songs, isPlaylist: true)
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
            artworkView

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

    @ViewBuilder
    private var artworkView: some View {
        AsyncImage(url: viewModel.song.artworkURL100) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                placeholderArtwork
            @unknown default:
                placeholderArtwork
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityHidden(true)
    }

    private var placeholderArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.secondary.opacity(0.15))

            Image(systemName: "music.note")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.secondary)
        }
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
