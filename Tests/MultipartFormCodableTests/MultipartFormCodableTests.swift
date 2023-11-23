//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
import MultipartFormCodable

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
}

