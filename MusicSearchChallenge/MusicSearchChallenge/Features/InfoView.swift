//
//  InfoView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SwiftUI

struct InfoView: View {
    let systemImageName: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImageName)
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(message))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, -100)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    InfoView(
        systemImageName: "magnifyingglass",
        message: String(localized: "search.idle.message")
    )
}
