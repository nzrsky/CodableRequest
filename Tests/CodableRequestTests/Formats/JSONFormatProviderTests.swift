//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

class JSONFormatProviderTests: XCTestCase {
    struct Foo: JSONFormatProvider {}

    func testJSONFormatProvider() {
        XCTAssertEqual(Foo.format, .json)
    }
}
