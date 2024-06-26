//
//  Please refer to the LICENSE file for licensing information.
//

import XCTest

func checkNoThrow<T>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = (#filePath),
    line: UInt = #line
) -> T? {
    var r: T?
    XCTAssertNoThrow(try {
        r = try expression()
    }(), message(), file: file, line: line)
    return r
}
