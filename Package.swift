// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Shrub",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "Shrub", targets: ["Shrub"]),
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Peek.git", .branch("trunk")),
        .package(url: "https://github.com/screensailor/Hope.git", .branch("trunk")),
        .package(url: "https://github.com/screensailor/combine-schedulers.git", .branch("trunk")),
    ],
    targets: [
        .target(
            name: "Shrub",
            dependencies: ["Peek"]
        ),
        .testTarget(
            name: "ShrubTests",
            dependencies: [
                "Shrub", "Hope", "Peek",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
    ]
)
