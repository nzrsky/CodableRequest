//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// A type that should encode itself to a JSON representation.
public typealias JSONEncodable = Encodable & JSONFormatProvider & JSONBodyProvider

public protocol JSONBodyProvider {
    associatedtype Body: Encodable

    static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }

    var body: Body { get }
}

public extension JSONBodyProvider {
    static var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { .convertToSnakeCase }
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .iso8601 }
}
