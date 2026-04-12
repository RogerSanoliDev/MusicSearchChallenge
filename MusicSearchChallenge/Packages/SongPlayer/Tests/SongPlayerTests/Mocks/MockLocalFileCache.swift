import Foundation
import Networking

final class MockLocalFileCache: LocalFileCaching, @unchecked Sendable {
    private let cachedResolvedURL: URL?
    private(set) var requestedKeys: [String] = []

    init(cachedResolvedURL: URL? = nil) {
        self.cachedResolvedURL = cachedResolvedURL
    }

    func resolvedURL(
        for remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    ) -> URL? {
        if let key {
            requestedKeys.append(key)
        }

        return cachedResolvedURL ?? remoteURL
    }

    func cachedFileURL(
        forKey key: String?,
        remoteURL: URL?,
        resourceType: LocalFileCacheResourceType
    ) -> URL? {
        cachedResolvedURL
    }

    func cacheFileIfNeeded(
        from remoteURL: URL?,
        key: String?,
        resourceType: LocalFileCacheResourceType
    ) {}
}
