//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

@propertyWrapper
public struct Cookies {
    public var wrappedValue: [HTTPCookie]

    public init(wrappedValue: [HTTPCookie] = []) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: Encodable

extension Cookies: Encodable {
    public func encode(to encoder: Encoder) throws {
        // This method needs to defined because `HTTPCookie` does not conform to `Encodable`, but should never be called anyways
        preconditionFailure("\(Self.self).encode(to encoder:) should not be called")
    }
}
