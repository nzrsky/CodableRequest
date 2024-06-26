//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

public struct DefaultHeaderStrategyOptional<RawValue>: ResponseHeaderDecodingStrategy where RawValue: Codable {

    public static func decode(decoder: Decoder) throws -> RawValue? {
        guard let key = decoder.codingPath.last?.stringValue else {
            throw ResponseHeaderDecodingError.missingCodingKey
        }
        
        // Check if the decoder is response decoder, otherwise fall back to default decoding logic
        guard let responseDecoding = decoder as? AnyResponseDecoding else {
            return try RawValue(from: decoder)
        }
        
        // Transform dash separator to camelCase
        guard let value: RawValue? = responseDecoding.valueForHeaderCaseInsensitive(key) else {
            return nil
        }
        
        return value
    }
}
