//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class ValidateStatus422ErrorBodyStrategyTests: XCTestCase {
    func testIsError_statusIs422_shouldBeTrue() {
        XCTAssertTrue(ValidateStatus422ErrorBodyStrategy.isError(statusCode: 422))
    }

    func testIsError_statusIsNot422_shouldBeFalse() {
        XCTAssertFalse(ValidateStatus422ErrorBodyStrategy.isError(statusCode: 999))
    }
}
