//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

// swiftlint: disable force_unwrapping

class ResponseStatusCodeCodingTests: XCTestCase {

    func testDecoding_noStatusCodeVariable_shouldDecodeWithoutStatusCode() {
        struct Response: Decodable {}

        let response = HTTPURLResponse(url: URL(string: "http://example.local")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let decoder = TestResponseDecoder()
        XCTAssertNoThrow(try decoder.decode(Response.self, from: (Data(), response)))
    }

    func testDecoding_singleStatusCodeVariable_shouldDecodeStatusCodeIntoVariable() {
        struct Response: Decodable {
            @StatusCode var statusCode
        }
        let response = HTTPURLResponse(url: URL(string: "http://example.local")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (Data(), response))) else {
            return
        }
        XCTAssertEqual(decoded.statusCode, 404)
    }

    func testDecoding_multipleStatusCodeVariables_shouldDecodeSameStatusCodeIntoAll() {
        struct Response: Decodable {
            @StatusCode var statusCode
            @StatusCode var statusCodeAgain
        }
        let response = HTTPURLResponse(url: URL(string: "http://example.local")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (Data(), response))) else {
            return
        }
        XCTAssertEqual(decoded.statusCode, 200)
        XCTAssertEqual(decoded.statusCode, 200)
        XCTAssertEqual(decoded.statusCodeAgain, 200)
    }
}

// swiftlint: enable force_unwrapping
