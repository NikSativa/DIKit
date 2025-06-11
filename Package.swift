// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .macCatalyst(.v14),
        .visionOS(.v1),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", from: "3.0.4"),
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.2.0")
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
