//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class OptionalContentStrategyTests: XCTestCase {
    func testAllowsEmptyContent_shouldAlwaysBeFalse() {
        XCTAssertFalse(OptionalContentStrategy.allowsEmptyContent(for: 200))
    }

    func testAllowsEmptyContent_statusCodeNoContent_shouldAlwaysBeFalse() {
        XCTAssertTrue(OptionalContentStrategy.allowsEmptyContent(for: 204))
    }

    func testValidateStatusCode_statusShouldMatchDefaultStrategy() {
        for statusCode in 0 ... 599 {
            XCTAssertEqual(OptionalContentStrategy.validate(statusCode: statusCode), DefaultBodyStrategy.validate(statusCode: statusCode))
        }
    }
}
