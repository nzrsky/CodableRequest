//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

// swiftlint: disable force_unwrapping

class ResponseBodyCodingTests: XCTestCase {

    let baseURL = URL(string: "https://test.local")!

    func testJSONResponseBodyDecoding_shouldDecodeEmptyBody() {
        struct Response: Decodable {
            struct Body: JSONDecodable {}
            @ResponseBody<Body> var body
        }
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = "{}".data(using: .utf8)!
        let decoder = TestResponseDecoder()
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
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
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
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNil(decoded.body)
    }

    func testJSONResponseBodyDecoding_strategiesSnakeIso() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var someDate: Date

                static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
                static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
            }

            @ResponseBody<Body> var body
        }
        
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "some_date": "1970-08-21T10:53:52Z"
        }
        """.data(using: .utf8)!
        
        let date = Date(timeIntervalSince1970: 1984 * 10_123)

        let decoder = ResponseDecoder<LoggingJSONDecoder.Provider>()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        
        XCTAssertEqual(decoded.body!.someDate, date)
    }


    func testJSONResponseBodyDecoding_strategiesSnakeCustom() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var someDate: Date

                static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
                static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
                    return .formatted(.stub)
                }
            }

            @ResponseBody<Body> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "some_date": "21-12-1970"
        }
        """.data(using: .utf8)!

        let decoder = ResponseDecoder<LoggingJSONDecoder.Provider>()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }

        XCTAssertEqual(DateFormatter.stub.string(from: decoded.body!.someDate), "21-12-1970")
    }

    func testJSONResponseBodyDecoding_strategiesInvalidKey() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var someDate: Date

                static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
                static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
            }

            @ResponseBody<Body> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "some_date": "1970-08-21T10:53:52Z"
        }
        """.data(using: .utf8)!

        let decoder = ResponseDecoder<LoggingJSONDecoder.Provider>()

        XCTAssertThrowsError(try decoder.decode(Response.self, from: (data, response))) { error in
            switch error {
            case let DecodingError.keyNotFound(key, _):
                XCTAssertEqual("\(key)", "CodingKeys(stringValue: \"someDate\", intValue: nil)")
            default:
                XCTFail("Unexpected error")
            }
        }
    }

    func testJSONResponseBodyDecoding_strategiesInvalidDate() {
        struct Response: Decodable {
            struct Body: JSONDecodable {
                var someDate: Date
                static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
            }

            @ResponseBody<Body> var body
        }

        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = """
        {
            "some_date": "21-12-1970"
        }
        """.data(using: .utf8)!

        let decoder = ResponseDecoder<LoggingJSONDecoder.Provider>()

        XCTAssertThrowsError(try decoder.decode(Response.self, from: (data, response))) { error in
            switch error {
            case DecodingError.dataCorrupted:
                XCTAssertTrue(true)
            default:
                XCTFail("Unexpected error")
            }
        }
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
        let decoder = TestResponseDecoder()
        guard let decoded = checkNoThrow(try decoder.decode(Response.self, from: (data, response))) else {
            return
        }
        XCTAssertNotNil(decoded.body)
        XCTAssertEqual(decoded.body, responseBody)
    }
}

extension DateFormatter {
    static let stub: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd-MM-yyyy"
        return fmt
    }()
}

// swiftlint: enable force_unwrapping

