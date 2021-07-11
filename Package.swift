// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Shrubbery",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "Shrubbery", targets: ["Shrubbery"]),
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Peek.git", .branch("trunk")),
        .package(url: "https://github.com/screensailor/Hope.git", .branch("trunk")),
    ],
    targets: [
        .target(
            name: "Shrubbery"
        ),
        .testTarget(
            name: "ShrubberyTests",
            dependencies: ["Shrubbery", "Peek", "Hope"]
        ),
    ]
)
