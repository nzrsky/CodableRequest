//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

class ResponseSingleValueDecodingContainer<JSONDecoderProvider: ResponseJSONDecoderProvider>: SingleValueDecodingContainer {

    let decoder: ResponseDecoding<JSONDecoderProvider>
    var codingPath: [CodingKey]

    init(decoder: ResponseDecoding<JSONDecoderProvider>, codingPath: [CodingKey]) {
        self.decoder = decoder
        self.codingPath = codingPath
    }

    func decodeNil() -> Bool {
        fatalError("not implemented")
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if type == StatusCode.self {
            guard let response = StatusCode(wrappedValue: UInt16(decoder.response.statusCode)) as? T else {
                preconditionFailure("Failed to cast ResponseStatusCode to type: \(type)")
            }
            return response
        }
        let decoding = ResponseDecoding<JSONDecoderProvider>(response: decoder.response, data: decoder.data, codingPath: codingPath)
        return try T(from: decoding)
    }
}
