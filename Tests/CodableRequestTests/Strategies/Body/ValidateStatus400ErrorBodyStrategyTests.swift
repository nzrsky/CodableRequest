//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class ValidateStatus400ErrorBodyStrategyTests: XCTestCase {
    func testIsError_statusIs400_shouldBeTrue() {
        XCTAssertTrue(ValidateStatus400ErrorBodyStrategy.isError(statusCode: 400))
    }

    func testIsError_statusIsNot400_shouldBeFalse() {
        XCTAssertFalse(ValidateStatus400ErrorBodyStrategy.isError(statusCode: 999))
    }
}
