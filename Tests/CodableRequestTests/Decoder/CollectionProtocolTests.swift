//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest
@testable import CodableRequest

class CollectionProtocolTests: XCTestCase {

    func testGetElementType_Set_shouldReturnElementType() {
        let erasedType: Any = type(of: [Int]())

        XCTAssertTrue(erasedType is CollectionProtocol.Type)
        XCTAssertTrue([Int].getElementType() is Int.Type)
    }

    func testGetElementType_Array_shouldReturnElementType() {
        let erasedType: Any = type(of: Set<Int>())
        
        XCTAssertTrue(erasedType is CollectionProtocol.Type)
        XCTAssertTrue(Set<Int>.getElementType() is Int.Type)
    }
}
