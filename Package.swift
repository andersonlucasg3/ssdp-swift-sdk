// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SSDP",
    platforms: [
        .iOS(.v10),
        .tvOS(.v11),
        .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "SSDP",
            targets: [ "SSDP" ]
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
        .package(url: "https://github.com/andersonlucasg3/CocoaAsyncSocket", .branch("master"))
    ],
    targets: [
        .target(
            name: "Socket"
        ),
        .target(
            name: "SSDP",
            dependencies: [ "CocoaAsyncSocket" ]
        ),
        .target(
            name: "AdvertiserSample",
            dependencies: [ "SSDP" ]
        ),
        .target(
            name: "SearcherSample",
            dependencies: [ "SSDP" ]
        )
    ]
)
