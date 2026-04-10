// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SongPlayer",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "SongPlayer",
            targets: ["SongPlayer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.2")
    ],
    targets: [
        .target(
            name: "SongPlayer"
        ),
        .testTarget(
            name: "SongPlayerTests",
            dependencies: [
                "SongPlayer",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
    ]
)
