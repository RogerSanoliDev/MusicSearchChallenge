//
//  SongListLoadingView.swift
//  MusicSearchChallenge
//
//  Created by Codex on 09/04/26.
//

import SwiftUI

struct SongListLoadingView: View {
    private let placeholderRows = Array(0..<5)

    var body: some View {
        List(placeholderRows, id: \.self) { _ in
            HStack(spacing: 12) {
                shimmerBlock(width: 60, height: 60, cornerRadius: 8)

                VStack(alignment: .leading, spacing: 8) {
                    shimmerBlock(width: 180, height: 20, cornerRadius: 6)
                    shimmerBlock(width: 120, height: 16, cornerRadius: 6)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .accessibilityHidden(true)
        }
        .preferredColorScheme(.dark)
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("search.loading.voiceover"))
    }

    private func shimmerBlock(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.secondary.opacity(0.15))
            .frame(width: width, height: height)
            .modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var shimmerOffset: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.12),
                            .clear,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: width * 1.5)
                    .offset(x: shimmerOffset * width * 2)
                    .blendMode(.plusLighter)
                }
                .mask(content)
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 1
                }
            }
    }
}

#Preview {
    SongListLoadingView()
}
