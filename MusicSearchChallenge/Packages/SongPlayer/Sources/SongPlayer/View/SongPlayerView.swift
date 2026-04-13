//
//  SongPlayerView.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import SwiftUI

public struct SongPlayerView: View {
    @State private var viewModel: SongPlayerViewModel

    public init(
        songs: [Song],
        startIndex: Int,
        onSongChange: ((Song) -> Void)? = nil,
        playbackController: SongPlaybackControlling = AVSongPlaybackController()
    ) {
        _viewModel = State(
            initialValue: SongPlayerViewModel(
                songs: songs,
                startIndex: startIndex,
                onSongChange: onSongChange,
                playbackController: playbackController
            )
        )
    }

    init(viewModel: SongPlayerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ArtworkView(url: viewModel.artworkURL)
                    .padding(.top, 48)

                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .bottom, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.trackName)
                                .font(.largeTitle.bold())
                                .lineLimit(2)

                            Text(viewModel.artistName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)

                        Button {
                            viewModel.toggleRepeat()
                        } label: {
                            Image(systemName: "repeat")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(viewModel.isRepeating ? Color.white : Color.secondary)
                                .padding(10)
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel(Text(localizedString("player.repeat")))
                        .accessibilityValue(Text(localizedString(viewModel.isRepeating ? "common.on" : "common.off")))
                    }

                    VStack(spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { viewModel.currentTime },
                                set: { viewModel.seek(to: $0) }
                            ),
                            in: 0...max(viewModel.duration, 0.1)
                        )
                        .tint(.white)
                        .accessibilityLabel(Text(localizedString("player.playback_position")))
                        .accessibilityValue(
                            Text(
                                String(
                                    format: localizedString("player.playback_position.value"),
                                    viewModel.elapsedTimeText,
                                    viewModel.durationText
                                )
                            )
                        )

                        HStack {
                            Text(viewModel.elapsedTimeText)
                            Spacer()
                            Text(viewModel.remainingTimeText)
                        }
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 36) {
                        Button {
                            viewModel.playPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title)
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel(Text(localizedString("player.previous")))

                        Button {
                            viewModel.togglePlayPause()
                        } label: {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28, weight: .bold))
                                .frame(width: 84, height: 84)
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel(Text(localizedString(viewModel.isPlaying ? "common.pause" : "common.play")))

                        Button {
                            viewModel.playNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.canPlayNext ? Color.white : Color.secondary.opacity(0.4))
                        }
                        .buttonStyle(.glass)
                        .disabled(!viewModel.canPlayNext)
                        .accessibilityLabel(Text(localizedString("player.next")))
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(viewModel.albumName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

private extension SongPlayerViewModel {
    var durationText: String {
        let totalSeconds = max(Int(duration.rounded(.down)), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private func localizedString(_ key: String) -> String {
    String(localized: String.LocalizationValue(key), bundle: .module)
}

#Preview {
    SongPlayerView(
        songs: [
            Song(
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
        ],
        startIndex: 0
    )
}
