//
//  ArtworkView.swift
//  SongPlayer
//
//  Created by Roger dos Santos Oliveira on 10/04/26.
//

import SwiftUI

struct ArtworkView: View {
    private let url: URL?
    
    init(url: URL?) {
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
        AsyncImage(url: url) { phase in
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
}

#Preview {
    ArtworkView(url: nil)
}
