// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CodableRequest",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "CodableRequest", targets: ["CodableRequest"]),
        .library(name: "CodableREST", targets: ["CodableREST", "CodableRequest"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodableRequestMock", dependencies: ["CodableRequest"]),

        .target(name: "CodableREST", dependencies: ["CodableRequest"]),
        .testTarget(name: "CodableRESTTests", dependencies: ["CodableRequest", "CodableREST", "CodableRequestMock"]),

        .target(name: "CodableRequest", dependencies: ["StringCaseConverter"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableRequest", "CodableREST", "CodableRequestMock"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"]),
    ]
)
