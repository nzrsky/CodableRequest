//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableREST
@testable import CodableRequest

class RequestEncoderTests: XCTestCase {

    let baseURL = URL(string: "https://CodableRequest.local")!

    func testEncodePlain_bodyHasInvalidCoding_shouldThrowError() async {
        struct Foo: PlainRequest {
            typealias Response = EmptyResponse
            var body: String
            var encoding: String.Encoding {
                .ascii
            }
        }
        let encoding: String.Encoding = .ascii
        let request = Foo(body: "🔥")
        let encoder = RequestEncoder(baseURL: baseURL)
        XCTAssertThrowsError(try encoder.encodePlain(request: request)) { error in
            switch error {
            case CodableRequestError.failedToEncodePlainText(let failedEncoding):
                XCTAssertEqual(failedEncoding, encoding)
            default:
                XCTFail()
            }
        }
    }
}
