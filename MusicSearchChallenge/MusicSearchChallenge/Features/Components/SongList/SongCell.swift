//
//  SongCell.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import SwiftUI
import SongPlayer

struct SongCell: View {
    private let song: Song
    private let showsMoreOptionsButton: Bool
    private let onMoreOptionsTap: (() -> Void)?

    init(
        song: Song,
        showsMoreOptionsButton: Bool,
        onMoreOptionsTap: (() -> Void)? = nil
    ) {
        self.song = song
        self.showsMoreOptionsButton = showsMoreOptionsButton
        self.onMoreOptionsTap = onMoreOptionsTap
    }

    var body: some View {
        HStack(spacing: 12) {
            Thumbnail(
                url: song.artworkURL60,
                size: 60,
                cornerRadius: 8,
                iconSize: 22
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(.headline)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if showsMoreOptionsButton, let onMoreOptionsTap {
                Button(action: onMoreOptionsTap) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .accessibilityLabel(Text("common.more_options"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(
                String.localizedStringWithFormat(
                    NSLocalizedString(
                        "song_list.row.voiceover",
                        comment: "VoiceOver label for a song row with track name and artist name"
                    ),
                    song.trackName,
                    song.artistName
                )
            )
        )
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    let song = Song(
        collectionID: 2,
        trackID: 2,
        artistName: "Tool",
        collectionName: "Lateralus",
        trackName: "Lateralus",
        previewURL: nil,
        artworkURL30: nil,
        artworkURL60: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/fb/99/8c/fb998c1e-1a11-2434-0fa7-0d90beba5d2b/886447824764.jpg/60x60bb.jpg"),
        artworkURL100: nil,
        trackTimeMillis: 259000,
        isStreamable: true
    )
    SongCell(song: song, showsMoreOptionsButton: true, onMoreOptionsTap: nil)
}
