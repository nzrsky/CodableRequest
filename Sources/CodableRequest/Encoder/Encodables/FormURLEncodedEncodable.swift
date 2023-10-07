//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// A type that can decode itself from an external form-url encoded representation.
public typealias FormURLEncodedEncodable = Encodable & FormURLEncodedFormatProvider & FormURLEncodedBodyProvider

public protocol FormURLEncodedBodyProvider {
    associatedtype Body: Encodable
    var body: Body { get }
}
