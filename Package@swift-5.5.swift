// swift-tools-version:5.5
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "NInject",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "NInject", targets: ["NInject"]),
        .library(name: "NInjectTestHelpers", targets: ["NInjectTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/NSpry.git", .upToNextMajor(from: "2.1.4")),
    ],
    targets: [
        .target(name: "NInject",
                dependencies: [
                ],
                path: "Source",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .target(name: "NInjectTestHelpers",
                dependencies: [
                    "NInject",
                    "NSpry"
                ],
                path: "TestHelpers",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "NInjectTests",
                    dependencies: [
                        "NInject",
                        "NInjectTestHelpers",
                        "NSpry",
                    ],
                    path: "Tests")
    ]
)
