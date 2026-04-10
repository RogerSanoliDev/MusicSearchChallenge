import Testing
@testable import SongPlayer

struct TimeFormatterTests {
    private let sut = TimeFormatter()

    @Test
    func formatTime_withZeroSeconds_returnsZeroTime() {
        #expect(sut.formatTime(0) == "0:00")
    }

    @Test
    func formatTime_withFractionalSeconds_roundsDown() {
        #expect(sut.formatTime(86.9) == "1:26")
    }

    @Test
    func formatTime_withNegativeValue_clampsToZero() {
        #expect(sut.formatTime(-12) == "0:00")
    }

    @Test
    func formatTime_withMinutesAndSeconds_formatsWithPaddedSeconds() {
        #expect(sut.formatTime(754) == "12:34")
    }
}
