//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class RequestPathParameterCodingTests: XCTestCase {

    let baseURL = URL(string: "https://local.url")!

    func testEncoding_missingParameter_shouldNotBeReplacedInPath() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/some-path/{unknown_id}/more-path"
        }
        let request = Request()
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/some-path/{unknown_id}/more-path")
    }

    func testEncoding_unnamedParameter_shouldReplaceValueInPathByVariableName() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/some-path/{id}/more-path"
            @PathParameter var id: Int
        }
        let request = Request(id: 123)
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/some-path/123/more-path")
    }

    func testEncoding_namedParameter_shouldReplaceValueInPathByVariableName() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/some-path/{custom_id}/more-path"
            @PathParameter(name: "custom_id") var otherId: Int
        }
        var request = Request()
        request.otherId = 456
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/some-path/456/more-path")
    }

    func testEncoding_multipleNamedParameters_shouldFailWithRangeOutOfBoundsIfAnyRegression() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/some-path/{some_id}/{id}"
            @PathParameter(name: "some_id") var someID: Int
            @PathParameter var id: Int
        }
        let request = Request(someID: 123, id: 456)

        // Only fails if regression was made.
        XCTAssert(encodeRequest(request: request) != nil, "Range out of bounds")
    }

    func testEncoding_multipleOccurrencesSameKey_shouldReplaceAllOccurrencesInPath() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/some/{id}/and/more/{id}/later"
            @PathParameter var id: Int
        }
        let request = Request(id: 123)
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/some/123/and/more/123/later")
    }

    func testEncoding_emptyPath_shouldIgnorePathParameters() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = ""

            @PathParameter var id: Int
            @PathParameter var name: String
        }
        let request = Request(id: 1, name: "some_name")
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "")
    }

    func testEncoding_stringParameter_shouldBePercentageEscaped() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{name}"
            @PathParameter var name: String
        }
        let request = Request(name: "some name")
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://local.url/some%20name")
    }

    func testEncoding_stringParameterCustomNaming_shouldUseCustomName() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{another_name}"
            @PathParameter(name: "another_name") var name: String
        }
        var request = Request()
        request.name = "some name"
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://local.url/some%20name")
    }

    func testEncoding_intParameterCustomNaming_shouldUseCustomName() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{my_id}"
            @PathParameter(name: "my_id") var id: Int
        }
        var request = Request()
        request.id = 123
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/123")
    }

    func testEncoding_stringParameterCustomNamingDefaultValue_shouldUseDefaultValue() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{another_name}"
            @PathParameter(name: "another_name", defaultValue: "default") var name: String
        }
        let request = Request()
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/default")
    }

    func testEncoding_optionalStringParameter_shouldBeReplacedWithLiteralNil() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{name}"
            @PathParameter var name: String?
        }
        let request = Request()
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/nil")
    }

    func testEncoding_optionalIntParameter_shouldBeReplacedWithLiteralNil() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{id}"
            @PathParameter var id: Int?
        }
        let request = Request()
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/nil")
    }

    func testEncoding_optionalParamIsGiven_shouldSerializedWrappedValue() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{id}"
            @PathParameter var id: Int?
        }
        var request = Request()
        request.id = 321
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.path, "/321")
    }

    func testEncoding_paramValueContainsUnescapedCharacters_shouldEscapeCharacters() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @Path var path = "/{id}"
            @PathParameter var id: String?
        }
        var request = Request()
        request.id = "{ABC}"
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://local.url/%7BABC%7D")
    }

    internal func encodeRequest<T: Encodable>(request: T, file: StaticString = #filePath, line: UInt = #line) -> URLRequest? {
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encode(request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription, file: file, line: line)
            return nil
        }
        return encoded
    }
}
