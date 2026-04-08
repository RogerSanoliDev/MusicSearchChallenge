//
//  SplashView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 08/04/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0, green: 134 / 255, blue: 160 / 255),
                .black,
            ],
            startPoint: .topTrailing,
            endPoint: .leading
        )
            .overlay {
                Image("splash_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
