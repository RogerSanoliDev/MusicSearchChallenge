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
            ZStack {
                VStack {
                    Spacer()
                    
                    Image("splash_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    Text("Music Search Challenge\nby Roger Oliveira")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
