//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// A type that can decode itself from an external form-url encoded representation.
public typealias MultipartFormEncodable = Encodable & MultipartFormFormatProvider & MultipartFormBodyProvider

public protocol MultipartFormBodyProvider {
    associatedtype Body: Encodable
    var body: Body { get }
}
