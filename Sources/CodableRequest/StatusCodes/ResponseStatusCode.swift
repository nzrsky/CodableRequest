//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

@propertyWrapper
public struct StatusCode: Decodable {

    public var wrappedValue: UInt16

    public init() {
        self.wrappedValue = 0
    }

    public init(wrappedValue: UInt16) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: HTTPStatusCode? {
        HTTPStatusCode(rawValue: wrappedValue)
    }
}
