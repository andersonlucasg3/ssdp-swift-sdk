// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SSDP",
    platforms: [
        .iOS(.v10),
        .tvOS(.v11)
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
         .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "1.0.0"),
         .package(url: "https://github.com/pierrickrouxel/SSDPClient", .branch("master"))
    ],
    targets: [
        .target(
            name: "SSDP",
            dependencies: [ "Socket" ]
        ),
        .target(
            name: "AdvertiserSample",
            dependencies: [ "SSDP" ]
        ),
        .target(
            name: "SearcherSample",
            dependencies: [ "SSDP" ]
        ),
        .target(
            name: "SSDPClientSample",
            dependencies: [ "SSDPClient" ],
            swiftSettings: [
                .define("DEBUG", .when(platforms: nil, configuration: .debug))
            ]
        )
    ]
)
