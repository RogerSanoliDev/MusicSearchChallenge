//
//  ArtworkView.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import Networking
import SwiftUI

struct ArtworkView: View {
    private let localFileCache: LocalFileCaching
    private let url: URL?

    init(
        url: URL?,
        localFileCache: LocalFileCaching = LocalFileCache.shared
    ) {
        self.localFileCache = localFileCache
        self.url = url
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.secondary.opacity(0.15))
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 72))
                    .foregroundStyle(.secondary)
            }
    }

    var body: some View {
        AsyncImage(url: resolvedImageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .interpolation(.high)
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                placeholderArtwork
            @unknown default:
                placeholderArtwork
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityHidden(true)
        .preferredColorScheme(.dark)
    }

    private var resolvedImageURL: URL? {
        localFileCache.resolvedURL(
            for: url,
            key: nil,
            resourceType: .image
        )
    }
}

#Preview {
    ArtworkView(url: nil)
}
