//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import MultipartFormCodable

// swiftlint: disable force_try line_length

class MultipartFormEncoderTests: XCTestCase {

    func testBasicEncoding() throws {
        struct TestStruct: Encodable, MultipartFormElementConvertible {
            let id: Int
            let name: String

            func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
                var data = Data()
                data.append("--\(boundary)\r\n")
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                data.append("\(id)\r\n")
                data.append("--\(boundary)\r\n")
                data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n")
                data.append("\(name)\r\n")
                data.append("--\(boundary)--\r\n")
                return data
            }
        }

        let testObject = TestStruct(id: 123, name: "John Doe")
        let encoder = MultipartFormEncoder()
        let encodedData = try encoder.encode(testObject)
        let expectedString = "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"id\"\r\n\r\n123\r\n--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nJohn Doe\r\n--\(encoder.boundary)--\r\n"
        XCTAssertEqual(String(data: encodedData, encoding: .utf8), expectedString)
    }
    
    func testRawRepresentableEnumEncoding() {
        enum Status: String, Encodable, MultipartFormElementConvertible {
            case active
            case inactive

            func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
                let part = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(self.rawValue)\r\n"
                return Data(part.utf8)
            }
        }

        struct Container: Encodable {
            let status: Status
        }

        let testObject = Container(status: .active)
        let encoder = MultipartFormEncoder()
        let encodedData = try! encoder.encode(testObject)
        let expectedString = "--\(encoder.boundary)\r\nContent-Disposition: form-data; name=\"status\"\r\n\r\nactive\r\n--\(encoder.boundary)--\r\n"
        XCTAssertEqual(String(data: encodedData, encoding: .utf8), expectedString)
    }
}

// swiftlint: enable force_try line_length
