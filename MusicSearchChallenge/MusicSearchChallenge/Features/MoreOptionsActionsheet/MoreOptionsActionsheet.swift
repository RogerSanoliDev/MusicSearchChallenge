import SwiftUI
import SongPlayer

struct MoreOptionsActionsheet: View {
    private let song: Song
    private let onViewAlbum: () -> Void

    init(
        song: Song,
        onViewAlbum: @escaping () -> Void
    ) {
        self.song = song
        self.onViewAlbum = onViewAlbum
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .center, spacing: 4) {
                Text(song.trackName)
                    .font(.headline)
                    .lineLimit(2)

                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Button() {
                onViewAlbum()
            } label : {
                HStack(spacing: 12) {
                    Image(systemName: "music.note.square.stack")
                        .font(.title3)
                        .padding(.leading, 20)
                    Text("more_options.view_album")
                        .font(.body.weight(.medium))
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("more_options.view_album"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MoreOptionsActionsheet(
        song:
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
            ),
        onViewAlbum: {}
    )
}
