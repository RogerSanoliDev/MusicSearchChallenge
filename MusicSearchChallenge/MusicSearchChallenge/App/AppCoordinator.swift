//
//  AppCoordinator.swift
//  MusicSearchChallenge
//
//  Created by Codex on 11/04/26.
//

import SwiftUI
import Observation
import SongPlayer

@MainActor
@Observable
final class AppCoordinator {
    struct PlayerContext: Hashable {
        let id = UUID()
        let songs: [Song]
        let startIndex: Int

        static func == (lhs: PlayerContext, rhs: PlayerContext) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    enum Page: Hashable, Identifiable {
        case songSearch
        case songPlayer(PlayerContext)
        case album(Song)
        case moreOptions(Song)

        var id: String {
            switch self {
            case .songSearch:
                "songSearch"
            case .songPlayer(let context):
                "songPlayer-\(context.id)"
            case .album(let song):
                "album-\(song.trackID)"
            case .moreOptions(let song):
                "moreOptions-\(song.trackID)"
            }
        }

        static func == (lhs: Page, rhs: Page) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    let rootPage: Page = .songSearch
    var path: [Page] = []
    var sheet: Page?

    func showSongPlayer(song: Song) {
        showSongPlayer(songs: [song], startIndex: 0)
    }

    func showSongPlayer(songs: [Song], startIndex: Int) {
        path.append(.songPlayer(PlayerContext(songs: songs, startIndex: startIndex)))
    }

    func showMoreOptions(for song: Song) {
        sheet = .moreOptions(song)
    }

    func showAlbum(for song: Song) {
        path.append(.album(song))
    }

    func closeSheet() {
        sheet = nil
    }

    func viewAlbum(from song: Song) {
        closeSheet()
        showAlbum(for: song)
    }

    func playAlbum(songs: [Song], startIndex: Int) {
        let playerPage = Page.songPlayer(PlayerContext(songs: songs, startIndex: startIndex))

        if let playerIndex = path.lastIndex(where: isSongPlayer) {
            path = Array(path.prefix(playerIndex)) + [playerPage]
            return
        }

        path.append(playerPage)
    }

    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .songSearch:
            SongSearchView(
                onSongSelected: showSongPlayer(song:),
                onMoreOptionsSelected: showMoreOptions(for:)
            )
        case .songPlayer(let context):
            SongPlayerContainerView(
                songs: context.songs,
                startIndex: context.startIndex,
                onMoreOptionsSelected: showMoreOptions(for:)
            )
        case .album(let song):
            AlbumView(
                song: song,
                onSongSelected: playAlbum(songs:startIndex:)
            )
        case .moreOptions:
            EmptyView()
        }
    }

    @ViewBuilder
    func buildSheet(page: Page) -> some View {
        switch page {
        case .moreOptions(let song):
            MoreOptionsActionsheet(song: song) {
                self.viewAlbum(from: song)
            }
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        default:
            EmptyView()
        }
    }

    private func isSongPlayer(_ page: Page) -> Bool {
        if case .songPlayer = page {
            true
        } else {
            false
        }
    }
}
