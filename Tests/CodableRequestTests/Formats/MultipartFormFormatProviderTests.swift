//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

class MultipartFormFormatProviderTests: XCTestCase {
    struct Foo: MultipartFormFormatProvider {}

    func testJSONFormatProvider() {
        XCTAssertEqual(Foo.format, .multipartForm)
    }
}
