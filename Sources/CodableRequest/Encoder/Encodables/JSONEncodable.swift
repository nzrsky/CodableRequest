//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// A type that should encode itself to a JSON representation.
public typealias JSONEncodable = Encodable & JSONFormatProvider & JSONBodyProvider

public protocol JSONBodyProvider {
    associatedtype Body: Encodable

    var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    
    var body: Body { get }
}

public extension JSONBodyProvider {
    var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { .convertToSnakeCase }
    var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .iso8601 }
}
