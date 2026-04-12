//
//  Thumbnail.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import Networking
import SwiftUI

struct Thumbnail: View {
    private let localFileCache: LocalFileCaching
    private let url: URL?
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private var iconSize: CGFloat
    
    init(
        url: URL?,
        size: CGFloat,
        cornerRadius: CGFloat,
        iconSize: CGFloat,
        localFileCache: LocalFileCaching = LocalFileCache.shared
    ) {
        self.localFileCache = localFileCache
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.iconSize = iconSize
    }
    
    var body: some View {
        AsyncImage(url: resolvedImageURL) { phase in
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
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
    
    private var placeholderArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.secondary.opacity(0.15))
            
            Image(systemName: "music.note")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    Thumbnail(
        url: nil,
        size: 100,
        cornerRadius: 18,
        iconSize: 44
    )
}
