//
//  Please refer to the LICENSE file for licensing information.
//

@testable import CodableRequest
import XCTest

class ValidateStatus401ErrorBodyStrategyTests: XCTestCase {
    func testIsError_statusIs401_shouldBeTrue() {
        XCTAssertTrue(ValidateStatus401ErrorBodyStrategy.isError(statusCode: 401))
    }

    func testIsError_statusIsNot401_shouldBeFalse() {
        XCTAssertFalse(ValidateStatus401ErrorBodyStrategy.isError(statusCode: 999))
    }
}
