//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

// swiftlint: disable force_unwrapping

class ResponseErrorBodyCodingTests: XCTestCase {

    let baseURL = URL(string: "https://test.local")!

    func testJSONResponseErrorBodyDecoding_shouldDecodeEmptyBody() {
        struct Response: Decodable {
            struct Body: JSONDecodable {}
            @ErrorBody<Body> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let data = "{}".data(using: .utf8)!
        let decoder = TestResponseDecoder()
        XCTAssertNoThrow(try decoder.decode(Response.self, from: (data, response)))
    }

    func testJSONResponseErrorBodyDecoding_valueInData_shouldDecodeFromData() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var value: String
            }
            @ErrorBody<Body> var body
        }
        
        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "value": "asdf"
        }
        """.data(using: .utf8)!

        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }

        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body?.value, "asdf")
    }

    func testJSONResponseErrorBodyDecoding_validStatusCode_shouldNotDecodeData() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var value: String
            }
            @ErrorBody<Body> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "value": "asdf"
        }
        """.data(using: .utf8)!

        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        
        XCTAssertNil(decoded.body)
    }

    func testPlainTextResponseErrorBodyDecoding_shouldReturnPlainTextBody() {
        struct Response: Decodable {
            @ErrorBody<PlainDecodable> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        
        let responseErrorBody = """
        {
            "value": "asdf"
        }
        """

        let data = responseErrorBody.data(using: .utf8)!
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body, responseErrorBody)
    }
}

// swiftlint: enable force_unwrapping
