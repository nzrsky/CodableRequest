//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class ResponseBodyCodingTests: XCTestCase {

    let baseURL = URL(string: "https://test.local")!

    func testJSONResponseBodyDecoding_shouldDecodeEmptyBody() {
        struct Response: Decodable {

            struct Body: JSONDecodable {}

            @ResponseBody<Body> var body
        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = "{}".data(using: .utf8)!
        let decoder = ResponseDecoder()
        XCTAssertNoThrow(try decoder.decode(Response.self, from: (data, response)))
    }

    func testJSONResponseBodyDecoding_valueInData_shouldDecodeFromData() {
        struct Response: Decodable {

            struct Body: JSONDecodable {
                var value: String
            }

            @ResponseBody<Body> var body
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
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body?.value, "asdf")
    }

    func testJSONResponseBodyDecoding_invalidStatusCode_shouldNotDecodeData() {
        struct Response: Decodable {

            struct Body: JSONDecodable {
                var value: String
            }

            @ResponseBody<Body> var body
        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 401, httpVersion: nil, headerFields: nil)!
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

    func testPlainTextResponseBodyDecoding_shouldReturnPlainTextBody() {
        struct Response: Decodable {

            @ResponseBody<PlainDecodable> var body
        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let responseBody = """
        {
            "value": "asdf"
        }
        """
        let data = responseBody.data(using: .utf8)!
        let decoder = ResponseDecoder()
        guard let decoded = CheckNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body, responseBody)
    }
}
