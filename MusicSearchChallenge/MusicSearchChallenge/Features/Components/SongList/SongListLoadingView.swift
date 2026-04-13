//
//  SongListLoadingView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 12/04/26.
//

import SwiftUI

struct SongListLoadingView: View {
    private let placeholderCount: Int

    init(placeholderCount: Int = 10) {
        self.placeholderCount = placeholderCount
    }

    var body: some View {
        List(0..<placeholderCount, id: \.self) { _ in
            SongCellLoadingView()
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("search.loading.voiceover"))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SongListLoadingView()
}
