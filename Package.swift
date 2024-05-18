// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "CodableRequest",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .watchOS(.v4), .tvOS(.v12)
    ],
    products: [
        .library(name: "CodableRequest", targets: ["CodableRequest"]),
        .library(name: "CodableURLSession", targets: ["CodableURLSession"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")
    ],
    targets: [
        .target(name: "CodableURLSessionMock", dependencies: ["CodableURLSession"]),

        .target(name: "URLEncodedFormCodable", dependencies: ["StringCaseConverter"]),
        .target(name: "MultipartFormCodable", dependencies: ["StringCaseConverter"]),

        .target(name: "CodableURLSession", dependencies: ["CodableRequest"],
                plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]),
        .testTarget(name: "CodableURLSessionTests", dependencies: ["CodableURLSessionMock"]),

        .target(name: "CodableRequest", dependencies: ["URLEncodedFormCodable", "MultipartFormCodable"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableRequest"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"]),
        .testTarget(name: "MultipartFormCodableTests", dependencies: ["MultipartFormCodable"])
    ]
)
