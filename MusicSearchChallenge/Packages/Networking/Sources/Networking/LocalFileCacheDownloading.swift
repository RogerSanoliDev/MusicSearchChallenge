import Foundation

public protocol LocalFileCacheDownloading: Sendable {
    func download(from remoteURL: URL, to localURL: URL) async throws
}

public struct URLSessionLocalFileCacheDownloader: LocalFileCacheDownloading {
    public init() {}

    public func download(from remoteURL: URL, to localURL: URL) async throws {
        let (temporaryURL, _) = try await URLSession.shared.download(from: remoteURL)

        if FileManager.default.fileExists(atPath: localURL.relativePath) {
            try? FileManager.default.removeItem(at: localURL)
        }

        try FileManager.default.moveItem(at: temporaryURL, to: localURL)
    }
}
