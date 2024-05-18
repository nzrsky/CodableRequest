//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class DefaultErrorBodyStrategyTests: XCTestCase {
    func testIsError_statusBelow400_shouldNotBeAnError() {
        XCTAssertFalse(DefaultErrorBodyStrategy.isError(statusCode: 200))
        XCTAssertFalse(DefaultErrorBodyStrategy.isError(statusCode: 301))
        XCTAssertFalse(DefaultErrorBodyStrategy.isError(statusCode: 399))
    }

    func testIsError_statusGreaterThanEqual400_shouldBeAnError() {
        XCTAssertTrue(DefaultErrorBodyStrategy.isError(statusCode: 400))
        XCTAssertTrue(DefaultErrorBodyStrategy.isError(statusCode: 401))
        XCTAssertTrue(DefaultErrorBodyStrategy.isError(statusCode: 500))
    }
}
