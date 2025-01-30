// swift-tools-version:5.8
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "DIKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "DIKit", targets: ["DIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/SpryKit.git", .upToNextMinor(from: "3.0.2"))
    ],
    targets: [
        .target(name: "DIKit",
                dependencies: [
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
