//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// A type that can decode itself from an external JSON representation.
public typealias JSONDecodable = Decodable & JSONFormatProvider & JSONDecodingStrategiesProvider

public protocol JSONDecodingStrategiesProvider {
    static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

public extension JSONDecodingStrategiesProvider {
    static var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .iso8601 }
}
