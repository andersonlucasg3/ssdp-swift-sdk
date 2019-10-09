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
            targets: [
                "SSDP"
            ]
        )
    ],
    dependencies: [
         .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "1.0.50")
    ],
    targets: [
        .target(
            name: "SSDP",
            dependencies: [
                "Socket"
            ]
        )
    ]
)
