//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

class ResponseKeyedDecodingContainer<Key, JSONDecoderProvider: ResponseJSONDecoderProvider>: KeyedDecodingContainerProtocol where Key: CodingKey {
    var decoder: ResponseDecoding<JSONDecoderProvider>
    var codingPath: [CodingKey] = []
    var allKeys: [Key] = []

    init(decoder: ResponseDecoding<JSONDecoderProvider>, keyedBy _: Key.Type, codingPath: [CodingKey]) {
        self.decoder = decoder
        self.codingPath = codingPath
    }

    func contains(_ key: Key) -> Bool {
        decoder.response.value(forHTTPHeaderField: key.stringValue) != nil
    }

    func decodeNil(forKey _: Key) throws -> Bool {
        fatalError("not implemented")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let decoding = ResponseDecoding<JSONDecoderProvider>(
            response: decoder.response,
            data: decoder.data,
            codingPath: codingPath + [key]
        )
        let container = try decoding.singleValueContainer()
        return try container.decode(type)
    }

    func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type, forKey _: Key
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("not implemented")
    }

    func nestedUnkeyedContainer(forKey _: Key) throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    func superDecoder() throws -> Decoder {
        fatalError("not implemented")
    }

    func superDecoder(forKey _: Key) throws -> Decoder {
        fatalError("not implemented")
    }
}
