//
//  Please refer to the LICENSE file for licensing information.
//

import Combine
import Foundation

public class ResponseDecoder<JSONDecoderProvider: ResponseJSONDecoderProvider> {
    public init() {}
    
    public func decode<T>(_ type: T.Type, from: (data: Data, response: HTTPURLResponse)) throws -> T where T: Decodable {
        let decoder = ResponseDecoding<JSONDecoderProvider>(response: from.response, data: from.data)
        return try T(from: decoder)
    }
}

extension ResponseDecoder: TopLevelDecoder {}
