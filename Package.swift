// swift-tools-version:5.3

import PackageDescription

#if TARGET_OS_MAC
let exclude = ["Resources"]
#else
let exclude = ["Resources/cocoapods"]
#endif

// swiftformat:disable all
let package = Package(
    name: "NInject",
    platforms: [.iOS(.v12), .macOS(.v10_12)],
    products: [
        .library(name: "NInject", targets: ["NInject"]),
        .library(name: "NInjectTestHelpers", targets: ["NInjectTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/NSpry.git", .upToNextMajor(from: "1.2.7")),
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.1"))
    ],
    targets: [
        .target(name: "NInject",
                dependencies: [
                ],
                path: "Source"),
        .target(name: "NInjectTestHelpers",
                dependencies: [
                    "NInject",
                    "NSpry"
                ],
                path: "TestHelpers"),
        .testTarget(name: "NInjectTests",
                    dependencies: [
                        "NInject",
                        "NInjectTestHelpers",
                        "NSpry",
                        .product(name: "NSpry_Nimble", package: "NSpry"),
                        "Nimble",
                        "Quick"
                    ],
                    path: "Tests",
                    exclude: exclude)
    ],
    swiftLanguageVersions: [.v5]
)
