// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Postie",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "Postie", targets: ["Postie"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Postie", dependencies: [
            "StringCaseConverter"
        ]),

        .target(name: "PostieMock", dependencies: ["Postie"]),
        .testTarget(name: "PostieTests", dependencies: ["Postie", "PostieMock"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"]),
    ]
)
