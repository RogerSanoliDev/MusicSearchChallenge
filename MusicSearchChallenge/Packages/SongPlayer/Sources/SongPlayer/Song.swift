import Foundation

public struct Song: Sendable, Equatable, Identifiable {
    public let collectionID: Int
    public let trackID: Int
    public let artistName: String
    public let collectionName: String
    public let trackName: String
    public let previewURL: URL?
    public let artworkURL30: URL?
    public let artworkURL60: URL?
    public let artworkURL100: URL?
    public let trackTimeMillis: Int
    public let isStreamable: Bool

    public init(
        collectionID: Int,
        trackID: Int,
        artistName: String,
        collectionName: String,
        trackName: String,
        previewURL: URL?,
        artworkURL30: URL?,
        artworkURL60: URL?,
        artworkURL100: URL?,
        trackTimeMillis: Int,
        isStreamable: Bool
    ) {
        self.collectionID = collectionID
        self.trackID = trackID
        self.artistName = artistName
        self.collectionName = collectionName
        self.trackName = trackName
        self.previewURL = previewURL
        self.artworkURL30 = artworkURL30
        self.artworkURL60 = artworkURL60
        self.artworkURL100 = artworkURL100
        self.trackTimeMillis = trackTimeMillis
        self.isStreamable = isStreamable
    }
    
    public var id: Int {
        trackID
    }
}
