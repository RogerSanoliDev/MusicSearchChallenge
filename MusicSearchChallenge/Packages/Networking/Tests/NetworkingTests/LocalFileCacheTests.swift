import Foundation
import Testing
@testable import Networking

struct LocalFileCacheTests {
    @Test
    func resolvedURL_returnsLocalFile_whenResourceIsAlreadyCached() throws {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let cachedFileURL = directoryURL
            .appendingPathComponent("LocalFileCache/audio", isDirectory: true)
            .appendingPathComponent("42.m4a")
        try FileManager.default.createDirectory(at: cachedFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("cached".utf8).write(to: cachedFileURL)

        let sut = LocalFileCache(
            cachesDirectoryURL: directoryURL,
            downloader: MockLocalFileCacheDownloader()
        )

        let result = sut.resolvedURL(
            for: URL(string: "https://example.com/preview.m4a"),
            key: "42",
            resourceType: .audio
        )

        #expect(result == cachedFileURL)
    }

    @Test
    func resolvedURL_returnsRemoteURL_andSchedulesBackgroundCaching_whenResourceIsNotCached() async throws {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let downloader = MockLocalFileCacheDownloader()
        let scheduledTask = TaskRecorder()
        let remoteURL = try #require(URL(string: "https://example.com/preview.m4a"))
        let sut = LocalFileCache(
            cachesDirectoryURL: directoryURL,
            downloader: downloader,
            scheduleBackgroundTask: { operation in
                scheduledTask.record(operation: operation)
            }
        )

        let result = sut.resolvedURL(for: remoteURL, key: "7", resourceType: .audio)

        #expect(result == remoteURL)

        let operation = try #require(scheduledTask.firstOperation())
        await operation()

        #expect(await downloader.downloadedURLs == [remoteURL])
        #expect(
            sut.cachedFileURL(
                forKey: "7",
                remoteURL: remoteURL,
                resourceType: .audio
            ) != nil
        )
    }

    @Test
    func cacheFileIfNeeded_prunesOldestAudioFiles_whenLimitIsExceeded() async throws {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let downloader = MockLocalFileCacheDownloader()
        let sut = LocalFileCache(
            cachesDirectoryURL: directoryURL,
            downloader: downloader,
            scheduleBackgroundTask: { operation in
                Task {
                    await operation()
                }
            }
        )

        for trackID in 1...11 {
            let remoteURL = try #require(URL(string: "https://example.com/\(trackID).m4a"))
            sut.cacheFileIfNeeded(from: remoteURL, key: "\(trackID)", resourceType: .audio)
            try await Task.sleep(for: .milliseconds(20))
        }

        try await Task.sleep(for: .milliseconds(100))

        #expect(
            sut.cachedFileURL(
                forKey: "1",
                remoteURL: URL(string: "https://example.com/1.m4a"),
                resourceType: .audio
            ) == nil
        )
        #expect(
            sut.cachedFileURL(
                forKey: "11",
                remoteURL: URL(string: "https://example.com/11.m4a"),
                resourceType: .audio
            ) != nil
        )
    }

    @Test
    func cacheFileIfNeeded_prunesOldestImageFiles_whenLimitIsExceeded() async throws {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let downloader = MockLocalFileCacheDownloader()
        let sut = LocalFileCache(
            cachesDirectoryURL: directoryURL,
            downloader: downloader,
            scheduleBackgroundTask: { operation in
                Task {
                    await operation()
                }
            }
        )

        for index in 1...101 {
            let remoteURL = try #require(URL(string: "https://example.com/\(index).jpg"))
            sut.cacheFileIfNeeded(from: remoteURL, key: "image-\(index)", resourceType: .image)
            try await Task.sleep(for: .milliseconds(5))
        }

        try await Task.sleep(for: .milliseconds(100))

        #expect(
            sut.cachedFileURL(
                forKey: "image-1",
                remoteURL: URL(string: "https://example.com/1.jpg"),
                resourceType: .image
            ) == nil
        )
        #expect(
            sut.cachedFileURL(
                forKey: "image-101",
                remoteURL: URL(string: "https://example.com/101.jpg"),
                resourceType: .image
            ) != nil
        )
    }

    @Test
    func cachedFileURL_generatesStableImageKeyFromRemoteURL_whenExplicitKeyIsMissing() async throws {
        let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let remoteURL = try #require(URL(string: "https://example.com/artwork/cover.jpg"))
        let downloader = MockLocalFileCacheDownloader()
        let sut = LocalFileCache(
            cachesDirectoryURL: directoryURL,
            downloader: downloader,
            scheduleBackgroundTask: { operation in
                Task {
                    await operation()
                }
            }
        )

        sut.cacheFileIfNeeded(from: remoteURL, key: nil, resourceType: .image)
        try await Task.sleep(for: .milliseconds(50))

        #expect(
            sut.cachedFileURL(
                forKey: nil,
                remoteURL: remoteURL,
                resourceType: .image
            ) != nil
        )
    }
}

private final class TaskRecorder: @unchecked Sendable {
    private var operation: (@Sendable () async -> Void)?

    func record(operation: @escaping @Sendable () async -> Void) {
        self.operation = operation
    }

    func firstOperation() -> (@Sendable () async -> Void)? {
        operation
    }
}

private actor MockLocalFileCacheDownloader: LocalFileCacheDownloading {
    private(set) var downloadedURLs: [URL] = []

    func download(from remoteURL: URL, to localURL: URL) async throws {
        downloadedURLs.append(remoteURL)
        try Data(remoteURL.absoluteString.utf8).write(to: localURL)
    }
}
