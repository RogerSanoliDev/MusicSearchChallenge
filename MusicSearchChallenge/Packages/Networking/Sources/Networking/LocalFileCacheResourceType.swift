import Foundation

public enum LocalFileCacheResourceType: Sendable {
    case audio
    case image

    var directoryName: String {
        switch self {
        case .audio:
            return "audio"
        case .image:
            return "image"
        }
    }

    var maximumItemCount: Int {
        switch self {
        case .audio:
            return 10
        case .image:
            return 100
        }
    }

    var defaultPathExtension: String {
        switch self {
        case .audio:
            return "m4a"
        case .image:
            return "img"
        }
    }
}
