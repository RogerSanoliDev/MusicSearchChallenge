//
//  Thumbnail.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import SwiftUI

struct Thumbnail: View {
    private let url: URL?
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private var iconSize: CGFloat
    
    init(
        url: URL?,
        size: CGFloat,
        cornerRadius: CGFloat,
        iconSize: CGFloat
    ) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        self.iconSize = iconSize
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
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
