import SnapshotTesting
import SwiftUI
import Testing
@testable import SongPlayer

@MainActor
struct SongPlayerViewTests {
    @Test(.snapshots(record: .missing))
    func songPlayerView_matchesSnapshot() {
        let playbackController = MockSongPlaybackController()
        playbackController.snapshot = SongPlaybackSnapshot(currentTime: 86, duration: 234, isPlaying: true)
        let viewModel = SongPlayerViewModel(
            songs: [
                .stub(
                    artistName: "Daft Punk feat. Pharrell Williams",
                    collectionName: "Random Access Memories",
                    trackName: "Get Lucky",
                    trackTimeMillis: 234_000
                )
            ],
            startIndex: 0,
            playbackController: playbackController
        )
        viewModel.onAppear()

        assertSnapshot(
            of: NavigationStack {
                SongPlayerView(viewModel: viewModel)
            },
            as: .image(
                layout: .device(config: .iPhone13),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }
}
