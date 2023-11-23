//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

fileprivate struct Request: Encodable {

    typealias Response = EmptyResponse

    @CodableRequest.Method var method
}

class RequestHTTPMethodCodingTests: XCTestCase {

    let baseURL = URL(string: "https://local.url")!

    func testEncoding_emptyMethod_shouldSetHttpMethodToGet() {
        let request = Request()
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.httpMethod, MethodValue.get.rawValue)
    }

    func testEncoding_methodSet_shouldUseSetHTTPMethod() {
        var request = Request()
        request.method = .post
        guard let urlRequest = encodeRequest(request: request) else {
            return
        }
        XCTAssertEqual(urlRequest.httpMethod, MethodValue.post.rawValue)
    }

    func testEncoding_duplicateMethods_shouldUseFirstOccurence() {
        struct Request: Encodable {

            typealias Response = EmptyResponse

            @CodableRequest.Method var method1 = .delete
            @CodableRequest.Method var method2 = .connect

        }
        guard let urlRequest = encodeRequest(request: Request()) else {
            return
        }
        XCTAssertEqual(urlRequest.httpMethod, MethodValue.connect.rawValue)
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
