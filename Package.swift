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
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2")
    ],
    targets: [
        .target(name: "CodableRequestMock", dependencies: ["CodableRequest"]),

        .target(name: "URLEncodedFormCodable", dependencies: ["StringCaseConverter"]),
        .target(name: "MultipartFormCodable", dependencies: ["StringCaseConverter"]),

        .target(name: "CodableREST", dependencies: ["CodableRequest"]),
        .testTarget(name: "CodableRESTTests", dependencies: ["CodableREST", "CodableRequestMock"], plugins: [
            .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
        ]),

        .target(name: "CodableRequest", dependencies: ["URLEncodedFormCodable", "MultipartFormCodable"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableREST", "CodableRequestMock"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"])
    ]
)
