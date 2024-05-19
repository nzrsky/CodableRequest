//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import MultipartFormCodable

// swiftlint: disable force_try line_length force_unwrapping

class MultipartFormCodableTests: XCTestCase {
    func testDefaultInitialization() {
        let encoder = MultipartFormEncoder()
        XCTAssertEqual(encoder.encoding, .utf8)
    }

    func testCustomInitialization() {
        let customEncoding = String.Encoding.ascii
        let encoder = MultipartFormEncoder(encoding: customEncoding)
        XCTAssertEqual(encoder.encoding, customEncoding)
    }

    func testIntEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: Int
        }
        
        XCTAssertEqual(
            String(data: try! encoder.encode(Body(param: 10)), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n10\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testStringEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: String
        }

        XCTAssertEqual(
            String(data: try! encoder.encode(Body(param: "foo")), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\nfoo\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testInt32Encoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: Int32
        }

        XCTAssertEqual(
            String(data: try! encoder.encode(Body(param: 32)), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n32\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testFloatEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: Float
        }

        XCTAssertEqual(
            String(data: try! encoder.encode(Body(param: 3.14)), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n3.14\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testDataEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        let data = "Example data".data(using: .utf8)!

        XCTAssertEqual(
            String(data: try! data.encodePart(using: .ascii, key: "file", boundary: encoder.boundary), encoding: .ascii)!,
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"file.octet-stream\"\r\nContent-Type: application/octet-stream\r\n\r\nExample data\r\n"
        )
    }

    func testArrayEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: [Int]
        }

        XCTAssertEqual(
            String(data: try! encoder.encode(Body(param: [1, 2, 3])), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n1\r\n--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n2\r\n--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"param\"\r\n\r\n3\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testDictionaryEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let params: [String: Int]
        }

        XCTAssertEqual(
            String(data: try! encoder.encode(Body(params: ["one": 1, "two": 2])), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"one\"\r\n\r\n1\r\n--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"two\"\r\n\r\n2\r\n--\(encoder.boundary)--\r\n"
        )
    }

    func testEncodingFailure() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        struct Body: Encodable {
            let param: String
        }

        XCTAssertThrowsError(try encoder.encode(Body(param: "测试"))) { error in
            XCTAssertTrue(error is MultipartFormEncoder.EncodingError)
        }
    }

    func testMime() {
        XCTAssertEqual(Data.nanoJpg.mimeType(), "image/jpeg")
        XCTAssertEqual(Data.nanoPng.mimeType(), "image/png")
        XCTAssertEqual(Data.nanoGif.mimeType(), "image/gif")
        XCTAssertEqual(Data.nanoTiffA.mimeType(), "image/tiff")
        XCTAssertEqual(Data.nanoTiffB.mimeType(), "image/tiff")
        XCTAssertEqual(Data.nanoPdf.mimeType(), "application/pdf")
        XCTAssertEqual(Data([UInt8](arrayLiteral: 0xde, 0xad, 0xbe, 0xef)).mimeType(), "application/octet-stream")
    }

    enum StatusCode: Int, MultipartFormElementConvertible {
        case ok = 200
        case notFound = 404
    }

    func testRawRepresentableEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        let status = StatusCode.ok

        XCTAssertEqual(
            String(data: try! status.encodePart(using: .ascii, key: "status", boundary: encoder.boundary), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"status\"\r\n\r\n200\r\n"
        )
    }

    func testBoolEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        let trueValue = true
        let falseValue = false

        XCTAssertEqual(
            String(data: try! trueValue.encodePart(using: .ascii, key: "trueParam", boundary: encoder.boundary), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"trueParam\"\r\n\r\ntrue\r\n"
        )

        XCTAssertEqual(
            String(data: try! falseValue.encodePart(using: .ascii, key: "falseParam", boundary: encoder.boundary), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"falseParam\"\r\n\r\nfalse\r\n"
        )
    }

    func testDecimalEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        let decimalValue = Decimal(string: "12345.6789")!

        XCTAssertEqual(
            String(data: try! decimalValue.encodePart(using: .ascii, key: "amount", boundary: encoder.boundary), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"amount\"\r\n\r\n12345.6789\r\n"
        )
    }

    func testURLEncoding() {
        let encoder = MultipartFormEncoder(encoding: .ascii)
        let url = URL(string: "http://example.com/path?query=1")!

        XCTAssertEqual(
            String(data: try! url.encodePart(using: .ascii, key: "website", boundary: encoder.boundary), encoding: .ascii),
            "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"website\"\r\n\r\nhttp://example.com/path?query=1\r\n"
        )
    }
}

extension Data {
    static let nanoJpg = Data(base64Encoded: "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=")!
    static let nanoPng = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII=")!
    static let nanoGif = Data(base64Encoded: "R0lGODlhAQABAAAAACw=")!
    static let nanoTiffA = Data(base64Encoded: "TU0AKgAAAAgAAwEAAAMAAAABAAEAAAEBAAMAAAABAAEAAAERAAMAAAABAAAAAA==")!
    static let nanoTiffB = Data(base64Encoded: "SUkqAAoAAAAAAAUAAAEDAAEAAAABAAAAAQEDAAEAAAABAAAAAwEDAAEAAAABAAAAEQEEAAEAAAAIAAAAFwEEAAEAAAABAAAA")!
    static let nanoPdf = Data(base64Encoded: "JVBERi0xLjIgCjkgMCBvYmoKPDwKPj4Kc3RyZWFtCkJULyAzMiBUZiggIFlPVVIgVEVYVCBIRVJFICAgKScgRVQKZW5kc3RyZWFtCmVuZG9iago0IDAgb2JqCjw8Ci9UeXBlIC9QYWdlCi9QYXJlbnQgNSAwIFIKL0NvbnRlbnRzIDkgMCBSCj4+CmVuZG9iago1IDAgb2JqCjw8Ci9LaWRzIFs0IDAgUiBdCi9Db3VudCAxCi9UeXBlIC9QYWdlcwovTWVkaWFCb3ggWyAwIDAgMjUwIDUwIF0KPj4KZW5kb2JqCjMgMCBvYmoKPDwKL1BhZ2VzIDUgMCBSCi9UeXBlIC9DYXRhbG9nCj4+CmVuZG9iagp0cmFpbGVyCjw8Ci9Sb290IDMgMCBSCj4+CiUlRU9G")!
}

// swiftlint: enable force_try line_length force_unwrapping
