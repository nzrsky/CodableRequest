//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

@propertyWrapper
public struct RequestURL: Encodable {
    public var wrappedValue: URL?

    public init(wrappedValue: URL? = nil) {
        self.wrappedValue = wrappedValue
    }
}
