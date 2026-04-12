import CryptoKit
import Foundation

public protocol LocalFileCaching: Sendable {
    func resolvedURL(
        for remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    ) -> URL?
    func cachedFileURL(
        forKey key: String?,
        remoteURL: URL?,
        resourceType: LocalFileCacheResourceType
    ) -> URL?
    func cacheFileIfNeeded(
        from remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    )
}

public final class LocalFileCache: LocalFileCaching, @unchecked Sendable {
    public static let shared = LocalFileCache()

    private let fileManager: FileManager
    private let cachesDirectoryURL: URL
    private let downloader: LocalFileCacheDownloading
    private let scheduleBackgroundTask: @Sendable (@escaping @Sendable () async -> Void) -> Void
    private let downloadRegistry = LocalFileCacheDownloadRegistry()

    public init(
        fileManager: FileManager = .default,
        cachesDirectoryURL: URL? = nil,
        downloader: LocalFileCacheDownloading = URLSessionLocalFileCacheDownloader(),
        scheduleBackgroundTask: @escaping @Sendable (@escaping @Sendable () async -> Void) -> Void = { operation in
            Task.detached(priority: .background) {
                await operation()
            }
        }
    ) {
        self.fileManager = fileManager
        self.cachesDirectoryURL = (cachesDirectoryURL ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory)
            .appendingPathComponent("LocalFileCache", isDirectory: true)
        self.downloader = downloader
        self.scheduleBackgroundTask = scheduleBackgroundTask
    }

    public func resolvedURL(
        for remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    ) -> URL? {
        if let localURL = cachedFileURL(forKey: key, remoteURL: remoteURL, resourceType: resourceType) {
            touchFileIfNeeded(at: localURL)
            return localURL
        }

        cacheFileIfNeeded(from: remoteURL, key: key, resourceType: resourceType)
        return remoteURL
    }

    public func cachedFileURL(
        forKey key: String?,
        remoteURL: URL?,
        resourceType: LocalFileCacheResourceType
    ) -> URL? {
        guard let cacheKey = cacheKey(for: remoteURL, key: key) else { return nil }

        let localURL = localFileURL(
            for: cacheKey,
            remoteURL: remoteURL,
            resourceType: resourceType
        )
        return fileManager.fileExists(atPath: localURL.relativePath) ? localURL : nil
    }

    public func cacheFileIfNeeded(
        from remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    ) {
        guard let remoteURL else { return }
        guard let cacheKey = cacheKey(for: remoteURL, key: key) else { return }
        guard cachedFileURL(forKey: cacheKey, remoteURL: remoteURL, resourceType: resourceType) == nil else { return }

        scheduleBackgroundTask { [weak self] in
            await self?.storeFileIfNeeded(
                from: remoteURL,
                cacheKey: cacheKey,
                resourceType: resourceType
            )
        }
    }

    private func storeFileIfNeeded(
        from remoteURL: URL,
        cacheKey: String,
        resourceType: LocalFileCacheResourceType
    ) async {
        let registryKey = registryKey(for: cacheKey, resourceType: resourceType)
        guard await downloadRegistry.beginDownload(for: registryKey) else { return }
        defer {
            Task {
                await downloadRegistry.finishDownload(for: registryKey)
            }
        }

        let localURL = localFileURL(
            for: cacheKey,
            remoteURL: remoteURL,
            resourceType: resourceType
        )

        guard cachedFileURL(forKey: cacheKey, remoteURL: remoteURL, resourceType: resourceType) == nil else {
            touchFileIfNeeded(at: localURL)
            return
        }

        do {
            let resourceDirectoryURL = directoryURL(for: resourceType)
            try createDirectoryIfNeeded(at: resourceDirectoryURL)

            if fileManager.fileExists(atPath: localURL.relativePath) {
                try? fileManager.removeItem(at: localURL)
            }

            try await downloader.download(from: remoteURL, to: localURL)
            touchFileIfNeeded(at: localURL)
            try pruneIfNeeded(for: resourceType)
        } catch {
            try? fileManager.removeItem(at: localURL)
        }
    }

    private func pruneIfNeeded(for resourceType: LocalFileCacheResourceType) throws {
        let resourceDirectoryURL = directoryURL(for: resourceType)
        guard fileManager.fileExists(atPath: resourceDirectoryURL.relativePath) else { return }

        let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey, .creationDateKey]
        let cachedFiles = try fileManager.contentsOfDirectory(
            at: resourceDirectoryURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        let overflow = cachedFiles.count - resourceType.maximumItemCount
        guard overflow > 0 else { return }

        let filesToRemove = cachedFiles
            .sorted { lhs, rhs in
                lastAccessDate(for: lhs) < lastAccessDate(for: rhs)
            }
            .prefix(overflow)

        for fileURL in filesToRemove {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    private func createDirectoryIfNeeded(at directoryURL: URL) throws {
        guard !fileManager.fileExists(atPath: directoryURL.relativePath) else { return }
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    private func touchFileIfNeeded(at fileURL: URL) {
        guard fileManager.fileExists(atPath: fileURL.relativePath) else { return }
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.relativePath)
    }

    private func lastAccessDate(for fileURL: URL) -> Date {
        let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .creationDateKey])
        return values?.contentModificationDate ?? values?.creationDate ?? .distantPast
    }

    private func directoryURL(for resourceType: LocalFileCacheResourceType) -> URL {
        cachesDirectoryURL.appendingPathComponent(resourceType.directoryName, isDirectory: true)
    }

    private func localFileURL(
        for cacheKey: String,
        remoteURL: URL?,
        resourceType: LocalFileCacheResourceType
    ) -> URL {
        directoryURL(for: resourceType)
            .appendingPathComponent(cacheKey)
            .appendingPathExtension(pathExtension(for: remoteURL, resourceType: resourceType))
    }

    private func pathExtension(
        for remoteURL: URL?,
        resourceType: LocalFileCacheResourceType
    ) -> String {
        let remoteExtension = remoteURL?.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return remoteExtension.isEmpty ? resourceType.defaultPathExtension : remoteExtension
    }

    private func cacheKey(for remoteURL: URL?, key: String?) -> String? {
        if let key, !key.isEmpty {
            return key
        }

        guard let remoteURL else { return nil }
        return sha256(remoteURL.absoluteString)
    }

    private func registryKey(for cacheKey: String, resourceType: LocalFileCacheResourceType) -> String {
        "\(resourceType.directoryName)-\(cacheKey)"
    }

    private func sha256(_ value: String) -> String {
        let digest = SHA256.hash(data: Data(value.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
