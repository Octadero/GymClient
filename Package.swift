// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GymClient",
    products: [
        .library(name: "GymClient", targets: ["GymClient"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GymClient", dependencies: []),
        .testTarget(name: "GymClientTests", dependencies: ["GymClient"]),
    ]
)
