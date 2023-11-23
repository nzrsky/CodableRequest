// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "CodableRequest",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .watchOS(.v4), .tvOS(.v12)
    ],
    products: [
        .library(name: "CodableRequest", targets: ["CodableRequest"]),
        .library(name: "CodableURLSession", targets: ["CodableURLSession"])
    ],
    dependencies: [],
    targets: [
        .target(name: "CodableURLSessionMock", dependencies: ["CodableRequest"]),

        .target(name: "URLEncodedFormCodable", dependencies: ["StringCaseConverter"]),
        .target(name: "MultipartFormCodable", dependencies: ["StringCaseConverter"]),

        .target(name: "CodableURLSession", dependencies: ["CodableRequest"]),
        .testTarget(name: "CodableURLSessionTests", dependencies: ["CodableURLSession", "CodableURLSessionMock"]),

        .target(name: "CodableRequest", dependencies: ["URLEncodedFormCodable", "MultipartFormCodable"]),
        .testTarget(name: "CodableRequestTests", dependencies: ["CodableRequest"]),

        .target(name: "StringCaseConverter"),
        .testTarget(name: "StringCaseConverterTests", dependencies: ["StringCaseConverter"]),
        .testTarget(name: "MultipartFormCodableTests", dependencies: ["MultipartFormCodable"])
    ]
)
