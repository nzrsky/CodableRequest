//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest
import MultipartFormCodable

class RequestBodyCodingTests: XCTestCase {

    let baseURL = URL(string: "https://local.url")!

    func testEncoding_emptyJsonBody_shouldEncodeToEmptyJsonAndSetContentTypeHeader() {
        struct Foo: JSONEncodable {

            struct Body: Encodable {}
            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body())
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeJson(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody!.json(), "{}".json())
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.json.rawValue)
    }

    func testEncoding_customJsonContentTypeHeader_shouldUseCustomHeader() {
        struct Foo: JSONEncodable {

            struct Body: Encodable {}
            typealias Response = EmptyResponse

            var body: Body

            @Header(name: "Content-Type") var customContentTypeHeader
        }

        var request = Foo(body: Foo.Body())
        request.customContentTypeHeader = "CodableRequest-test"
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeJson(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody!.json(), "{}".json())
        XCTAssertEqual(encoded.value(for: .contentType), "CodableRequest-test")
    }

    func testEncoding_nonEmptyJsonBody_shouldEncodeToValidJsonAndSetContentTypeHeader() {
        struct Foo: JSONEncodable {

            struct Body: Encodable {
                var value: Int
            }

            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body(value: 123))
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeJson(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody!.json(), #"{"value":123}"#.json())
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.json.rawValue)
    }

    func testEncoding_nonEmptyJSONBody_shouldEncodeToValidSnakeCaseJSON() {
        struct Foo: JSONEncodable {

            struct Body: Encodable {
                var someValue: Int
                var someOtherValue: String
            }

            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body(someValue: 123, someOtherValue: "Bar"))
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeJson(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody!.json(), #"{"some_other_value":"Bar","some_value":123}"#.json())
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.json.rawValue)
    }

    func testEncoding_nonEmptyJSONBody_shouldEncodeToValidCamelCaseJSON() {
        struct Foo: JSONEncodable {

            struct Body: Encodable {
                var someValue: Int
                var someOtherValue: String
            }

            typealias Response = EmptyResponse

            var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
                return .useDefaultKeys
            }

            var body: Body
        }

        let request = Foo(body: Foo.Body(someValue: 123, someOtherValue: "Bar"))
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeJson(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }

        XCTAssertEqual(encoded.httpBody!.json(), #"{"someValue":123,"someOtherValue":"Bar"}"#.json())
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.json.rawValue)
    }

    func testEncoding_emptyFormURLEncodedBody_shouldEncodeToEmptyBodyAndSetContentTypeHeader() {
        struct Foo: FormURLEncodedEncodable {

            struct Body: Encodable {}
            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body())
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeFormURLEncoded(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }

        XCTAssertEqual(encoded.httpBody, Data())
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.formUrlEncoded.rawValue)
    }

    func testEncoding_customFormURLEncodedContentTypeHeader_shouldUseCustomHeader() {
        struct Foo: FormURLEncodedEncodable {

            struct Body: Encodable {}
            typealias Response = EmptyResponse

            var body: Body

            @Header(name: "Content-Type") var customContentTypeHeader
        }

        var request = Foo(body: Foo.Body())
        request.customContentTypeHeader = "CodableRequest-test"
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeFormURLEncoded(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }

        XCTAssertEqual(encoded.httpBody, Data())
        XCTAssertEqual(encoded.value(for: .contentType), "CodableRequest-test")
    }

    func testEncoding_nonEmptyFormURLEncodedBody_shouldEncodeToValidFormURLEncodedStringAndSetContentTypeHeader() {
        struct Foo: FormURLEncodedEncodable {

            struct Body: Encodable {
                var value: Int
                var others: String
            }

            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body(value: 123, others: "This escaped string"))
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeFormURLEncoded(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody, "others=This%20escaped%20string&value=123".data(using: .utf8)!)
        XCTAssertEqual(encoded.value(for: .contentType), ContentTypeValue.formUrlEncoded.rawValue)
    }

    func testEncoding_nonEmptyPlainTextBody_shouldEncodeUsingDefaultEncoding() {
        struct Foo: PlainEncodable {

            typealias Response = EmptyResponse

            var body: String
        }

        let request = Foo(body: "some string")
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodePlain(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody, "some string".data(using: .utf8)!)
    }

    func testEncoding_nonEmptyPlainTextBodyCustomEncoding_shouldEncodeUsingCustomEncoding() {
        struct Foo: PlainEncodable {

            typealias Response = EmptyResponse

            var body: String
            var encoding: String.Encoding = .utf16
        }

        let request = Foo(body: "some string")
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodePlain(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }
        XCTAssertEqual(encoded.httpBody, "some string".data(using: .utf16)!)
    }

    func testEncoding_emptyMultipartFormBody_shouldEncodeToEmptyBodyAndSetContentTypeHeader() {
        struct Foo: MultipartFormEncodable {

            struct Body: Encodable {}
            typealias Response = EmptyResponse

            var body: Body
        }

        let request = Foo(body: Foo.Body())
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeMultipartForm(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }

        let header = encoded.value(for: .contentType)!
        let boundary =  header.components(separatedBy: "=")[1]

        XCTAssertEqual(encoded.httpBody!.str(), "--\(boundary)--\r\n")
        XCTAssertEqual(header, "\(ContentTypeValue.multipart.rawValue); boundary=\(boundary)")
    }

    func testEncoding_nonEmptyMultipartFormBody_shouldEncodeToValidMultipartFormStringAndSetContentTypeHeader() {
        struct Foo: MultipartFormEncodable {

            struct Body: Encodable {
                var title: String
                var value: Int
                var pic: Data
            }

            typealias Response = EmptyResponse

            var body: Body
        }

        let img = Data(base64Encoded: "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=")!
        let request = Foo(body: Foo.Body(title: "test", value: 123, pic: img))
        let encoder = RequestEncoder(baseURL: baseURL)
        let encoded: URLRequest
        do {
            encoded = try encoder.encodeMultipartForm(request: request)
        } catch {
            XCTFail("Failed to encode: " + error.localizedDescription)
            return
        }

        let header = encoded.value(for: .contentType)!
        let boundary =  header.components(separatedBy: "=")[1]
        let body = encoded.httpBody!.str()
        let prefix =  "--\(boundary)\r\nContent-Disposition: form-data; name=\"title\"\r\n\r\ntest\r\n" +
        "--\(boundary)\r\nContent-Disposition: form-data; name=\"value\"\r\n\r\n123\r\n" +
        "--\(boundary)\r\nContent-Disposition: form-data; name=\"pic\"; filename=\"pic.jpeg\"\r\nContent-Type: image/jpeg\r\n\r\n"

        XCTAssertEqual(String(body[body.startIndex ..< body.index(body.startIndex, offsetBy: prefix.count)]), prefix)
        XCTAssertTrue(body.hasSuffix("--\(boundary)--\r\n"))
        XCTAssertEqual(header, "\(ContentTypeValue.multipart.rawValue); boundary=\(boundary)")
    }
}

private extension Data {
    func json() -> [String: AnyHashable] {
        try! JSONSerialization.jsonObject(with: self, options: []) as! [String: AnyHashable]
    }

    func str() -> String {
        String(data: self, encoding: .ascii)!
    }
}

private extension String {
    func json() -> [String: AnyHashable] {
        data(using: .utf8)!.json()
    }
}
