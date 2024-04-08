// swift-tools-version:5.7
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"]),
        .library(name: "DIKitTestHelpers", targets: ["DIKitTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMajor(from: "2.2.0")),
    ],
    targets: [
        .target(name: "DIKit",
                dependencies: [
                ],
                path: "Source",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .target(name: "DIKitTestHelpers",
                dependencies: [
                    "DIKit",
                    "SpryKit"
                ],
                path: "TestHelpers",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "DIKitTests",
                    dependencies: [
                        "DIKit",
                        "DIKitTestHelpers",
                        "SpryKit",
                    ],
                    path: "Tests")
    ]
)
