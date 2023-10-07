// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CodableRequest",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(name: "CodableRequest", targets: ["CodableRequest"]),
        .library(name: "CodableREST", targets: ["CodableREST"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodableRequestMock", dependencies: ["CodableRequest"]),

        .target(name: "URLEncodedFormCodable", dependencies: ["StringCaseConverter"]),

        .target(name: "CodableREST", dependencies: ["CodableRequest"]),
        .testTarget(name: "CodableRESTTests", dependencies: ["CodableREST", "CodableRequestMock"]),

        .target(name: "CodableRequest", dependencies: ["StringCaseConverter", "URLEncodedFormCodable"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableREST", "CodableRequestMock"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"])
    ]
)
