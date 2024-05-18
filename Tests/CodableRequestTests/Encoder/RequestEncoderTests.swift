//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

// swiftlint: disable force_unwrapping

class RequestEncoderTests: XCTestCase {

    let baseURL = URL(string: "https://CodableRequest.local")!

    func testEncodePlain_bodyHasInvalidCoding_shouldThrowError() async {
        struct Foo: PlainRequest {
            typealias Response = EmptyResponse
            var body: String
            var encoding: String.Encoding {
                .ascii
            }
        }
        let encoding: String.Encoding = .ascii
        let request = Foo(body: "🔥")
        let encoder = RequestEncoder(baseURL: baseURL)
        XCTAssertThrowsError(try encoder.encodePlain(request: request)) { error in
            switch error {
            case CodableRequestError.failedToEncodePlainText(let failedEncoding):
                XCTAssertEqual(failedEncoding, encoding)
            default:
                XCTFail("unknown")
            }
        }
    }

    func testEncodeUrl_customUrlWithQueryItems_shouldBeIncludedInRequest() throws {
        // Arrange
        struct Foo: Request {
            typealias Response = EmptyResponse

            @Endpoint var url
        }
        var foo = Foo()
        foo.url = URL(string: "https://testing.local?field1=value")
        // Act
        let encoder = RequestEncoder(baseURL: baseURL)
        let request = try encoder.encode(foo)
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://testing.local?field1=value"))
    }

    func testEncodeUrl_customUrlWithQueryAndOtherQueryItems_shouldAllBeIncludedInRequest() throws {
        // Arrange
        struct Foo: Request {
            typealias Response = EmptyResponse

            @Endpoint var url
            @QueryItem(name: "field2") var field2: String?
        }
        var foo = Foo()
        foo.url = URL(string: "https://testing.local?field1=value1")
        foo.field2 = "value2"
        // Act
        let encoder = RequestEncoder(baseURL: baseURL)
        let request = try encoder.encode(foo)
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://testing.local?field1=value1&field2=value2"))
    }

    func testEncodeUrl_customUrlWithQueryAndSameQueryItems_shouldUseTheValueFromCustomUrlInRequest() throws {
        // Arrange
        struct Foo: Request {
            typealias Response = EmptyResponse

            @Endpoint var url
            @QueryItem(name: "field1") var field1: String?
        }
        var foo = Foo()
        foo.url = URL(string: "https://testing.local?field1=value1")
        foo.field1 = "value2"
        // Act
        let encoder = RequestEncoder(baseURL: baseURL)
        let request = try encoder.encode(foo)
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://testing.local?field1=value1"))
    }
}

// swiftlint: enable force_unwrapping
