// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Luno",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "Luno", targets: ["Luno"])
    ],
    targets: [
        .target(name: "Luno")
    ]
)
