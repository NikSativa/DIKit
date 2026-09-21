// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .macCatalyst(.v15),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"]),
        .library(name: "DIKitTesting", targets: ["DIKitTesting"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", from: "3.2.4"),
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.3.4")
    ],
    targets: [
        .target(name: "DIKit",
                dependencies: [
                    "Threading"
                ],
                path: "Source",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ]),
        .target(name: "DIKitTesting",
                dependencies: [
                    "DIKit"
                ],
                path: "DIKitTesting"),
        .testTarget(name: "DIKitTests",
                    dependencies: [
                        "DIKit",
                        "DIKitTesting",
                        "SpryKit",
                    ],
                    path: "Tests")
    ]
)
