// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CodableRequest",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "CodableRequest", targets: ["CodableRequest"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodableRequest", dependencies: [
            "StringCaseConverter"
        ]),

        .target(name: "CodableRequestMock", dependencies: ["CodableRequest"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableRequest", "CodableRequestMock"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"]),
    ]
)
