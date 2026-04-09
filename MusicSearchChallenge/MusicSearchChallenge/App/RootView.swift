//
//  RootView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 08/04/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        Group {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                SongSearchView()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.2), value: isShowingSplash)
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            isShowingSplash = false
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: Item.self, inMemory: true)
}
