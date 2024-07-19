// swift-tools-version:5.6
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"]),
        .library(name: "DIKitTestHelpers", targets: ["DIKitTestHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMajor(from: "2.2.3"))
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
