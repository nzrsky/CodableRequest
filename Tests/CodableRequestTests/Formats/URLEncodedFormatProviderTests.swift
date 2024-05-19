//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

class FormURLEncodedFormatProviderTests: XCTestCase {
    struct Foo: FormURLEncodedFormatProvider {}

    func testJSONFormatProvider() {
        XCTAssertEqual(Foo.format, .formURLEncoded)
    }
}
