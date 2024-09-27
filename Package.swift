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
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMajor(from: "2.3.9"))
    ],
    targets: [
        .target(name: "DIKit",
                dependencies: [
                ],
                path: "Source",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ],
                swiftSettings: [
                    .define("supportsVisionOS", .when(platforms: [.visionOS])),
                ]),
        .testTarget(name: "DIKitTests",
                    dependencies: [
                        "DIKit",
                        "SpryKit",
                    ],
                    path: "Tests",
                    swiftSettings: [
                        .define("supportsVisionOS", .when(platforms: [.visionOS])),
                    ])
    ]
)
