// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .macCatalyst(.v16),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", from: "3.1.0"),
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.2.1")
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
        .testTarget(name: "DIKitTests",
                    dependencies: [
                        "DIKit",
                        "SpryKit",
                    ],
                    path: "Tests")
    ]
)
