// swift-tools-version:5.8
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "NInject",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(name: "NInject", targets: ["NInject"]),
        .library(name: "NInjectTestHelpers", targets: ["NInjectTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/NSpry.git", .upToNextMajor(from: "2.0.1")),
    ],
    targets: [
        .target(name: "NInject",
                dependencies: [
                ],
                path: "Source"
               ),
        .target(name: "NInjectTestHelpers",
                dependencies: [
                    "NInject",
                    "NSpry"
                ],
                path: "TestHelpers"
               ),
        .testTarget(name: "NInjectTests",
                    dependencies: [
                        "NInject",
                        "NInjectTestHelpers",
                        "NSpry",
                    ],
                    path: "Tests"
                   )
    ]
)
