// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SsdpSdk",
    platforms: [
        .iOS(.v10),
        .tvOS(.v11),
        .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "SsdpSdk",
            targets: [ "SsdpSdk" ]
        ),
        .executable(
            name: "AdvertiserSample",
            targets: [ "AdvertiserSample" ]
        ),
        .executable(
            name: "SearcherSample",
            targets: ["SearcherSample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SsdpSdk",
            dependencies: [ "Socket" ]
        ),
        .target(
            name: "AdvertiserSample",
            dependencies: [ "SsdpSdk" ]
        ),
        .target(
            name: "SearcherSample",
            dependencies: [ "SsdpSdk" ]
        )
    ]
)
