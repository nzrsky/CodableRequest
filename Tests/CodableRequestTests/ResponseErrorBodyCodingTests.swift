//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

class ResponseErrorBodyCodingTests: XCTestCase {

    let baseURL = URL(string: "https://test.local")!
    
    func testJSONResponseErrorBodyDecoding_shouldDecodeEmptyBody() {
        struct Response: Decodable {

            struct Body: JSONDecodable {}

            @ErrorBody<Body> var body

        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let data = "{}".data(using: .utf8)!
        let decoder = ResponseDecoder()
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
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
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
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNil(decoded.body)
    }

    func testFormURLEncodedResponseErrorBodyDecoding_shouldDecodeEmptyBody() {
        struct Response: Decodable {

            struct Body: FormURLEncodedDecodable {}

            @ErrorBody<Body> var body

        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let data = "".data(using: .utf8)!
        let decoder = ResponseDecoder()
        XCTAssertNoThrow(try decoder.decode(Response.self, from: (data, response)))
    }

    func testFormURLEncodedResponseErrorBodyDecoding_valueInData_shouldDecodeFromData() {
        struct Response: Decodable {

            struct Body: FormURLEncodedDecodable {
                var value: String
            }

            @ErrorBody<Body> var body

        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let data = """
        value=asdf
        """.data(using: .utf8)!
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body?.value, "asdf")
    }

    func testFormURLEncodedResponseErrorBodyDecoding_validStatusCode_shouldNotDecodeData() {
        struct Response: Decodable {

            struct Body: FormURLEncodedDecodable {
                var value: String
            }

            @ErrorBody<Body> var body

        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        value=asdf
        """.data(using: .utf8)!
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNil(decoded.body)
    }

    func testPlainTextResponseErrorBodyDecoding_shouldReturnPlainTextBody() {
        struct Response: Decodable {

            @ErrorBody<PlainDecodable> var body

        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let ResponseErrorBody = """
        {
            "value": "asdf"
        }
        """
        let data = ResponseErrorBody.data(using: .utf8)!
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body, ResponseErrorBody)
    }
}
