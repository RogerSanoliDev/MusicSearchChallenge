//
//  SongListView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SwiftUI

struct SongListView: View {
    let songs: [Song]

    var body: some View {
        List(songs, id: \.trackID) { song in
            row(for: song)
        }
        .preferredColorScheme(.dark)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

    private var placeholderArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))

            Image(systemName: "music.note")
                .foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }

    private func row(for song: Song) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: song.artworkURL60) { phase in
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
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)

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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
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
