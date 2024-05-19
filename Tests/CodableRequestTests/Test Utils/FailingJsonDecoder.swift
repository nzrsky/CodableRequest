//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import CodableRequest

class TestResponseDecoder {
    required public init() {}

    public func decode<T>(_ type: T.Type, from: (data: Data, response: HTTPURLResponse)) throws -> T where T: Decodable {
        let decoder = ResponseDecoding<LoggingJSONDecoder.Provider>(response: from.response, data: from.data)
        return try T(from: decoder)
    }
}

