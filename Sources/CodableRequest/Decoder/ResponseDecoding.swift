//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import os.log
import StringCaseConverter

public protocol ResponseJSONDecoderProvider {
    static func decoder(
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    ) -> JSONDecoder
}

public protocol AnyResponseDecoding: Decoder {
    var response: HTTPURLResponse { get }
    var data: Data { get }
    func decodeBody<T: Decodable>(to type: T.Type) throws -> T
    func valueForHeaderCaseInsensitive<T>(_ header: String) -> T?
}

public struct ResponseDecoding<JSONDecoderProvider: ResponseJSONDecoderProvider>: AnyResponseDecoding {
    public var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    public var response: HTTPURLResponse
    public var data: Data

    public init(response: HTTPURLResponse, data: Data, codingPath: [CodingKey] = []) {
        self.response = response
        self.data = data
        self.codingPath = codingPath
    }

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = ResponseKeyedDecodingContainer(decoder: self, keyedBy: type, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        ResponseSingleValueDecodingContainer(decoder: self, codingPath: codingPath)
    }

    public func valueForHeaderCaseInsensitive<T>(_ header: String) -> T? {
        // Find case insensitive
        for (key, value) in response.allHeaderFields {
            guard let key = key.base as? String else {
                continue
            }
            let existingKey = key
                .split(separator: "-")
                .map(\.uppercasingFirst)
                .joined()
                .lowercased()

            if let value = value as? String, existingKey == header.lowercased() {
                switch T.self {
                case is IntegerLiteralType.Type, is IntegerLiteralType?.Type:
                    return Int(value) as? T

                default:
                    return value as? T
                }
            }
        }
        return nil
    }

    func valueForHeaderCaseSensitive(_ header: String) -> String? {
        response.value(forHTTPHeaderField: header)
    }

    func decodeBody<E: Decodable>(to type: [E].Type) throws -> [E] {
        fatalError("not implemented")
    }

    public func decodeBody<T: Decodable>(to type: T.Type) throws -> T {

        if type is PlainDecodable.Type {
            return try decodeString(type, from: data)
        }
        
        if let jsonType = type as? JSONDecodable.Type {
            let decoder = JSONDecoderProvider.decoder(
                keyDecodingStrategy: jsonType.keyDecodingStrategy,
                dateDecodingStrategy: jsonType.dateDecodingStrategy
            )
            return try decoder.decode(type, from: data)
        }

        if type is CollectionProtocol.Type {
            guard let collectionType = type as? CollectionProtocol.Type else {
                preconditionFailure("this cast should not fail, contact the developers!")
            }

            let elementType = collectionType.getElementType()

            if elementType is PlainDecodable.Type {
                return try decodeString(type, from: data)
            }
            
            if let jsonType = elementType as? JSONDecodable.Type {
                let decoder = JSONDecoderProvider.decoder(
                    keyDecodingStrategy: jsonType.keyDecodingStrategy,
                    dateDecodingStrategy: jsonType.dateDecodingStrategy
                )
                return try decoder.decode(type, from: data)
            }
        }

        // os_log("Unsupported body type: %@", type: .error, String(describing: type))

        throw DecodingError.typeMismatch(
            T.self,
            DecodingError.Context(
                codingPath: [],
                debugDescription: "Request failed, but it's failed to decode it to: \(type)"
            )
        )
    }

    private func decodeString<T>(_ type: T.Type, from data: Data) throws -> T {
        let encoding: String.Encoding = .utf8

        guard let value = String(data: data, encoding: encoding) as? T else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Failed to decode using encoding: \(encoding)"
            ))
        }

        return value
    }
}
