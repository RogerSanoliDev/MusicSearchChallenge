actor LocalFileCacheDownloadRegistry {
    private var inFlightKeys: Set<String> = []

    func beginDownload(for key: String) -> Bool {
        guard !inFlightKeys.contains(key) else { return false }
        inFlightKeys.insert(key)
        return true
    }

    func finishDownload(for key: String) {
        inFlightKeys.remove(key)
    }
}
