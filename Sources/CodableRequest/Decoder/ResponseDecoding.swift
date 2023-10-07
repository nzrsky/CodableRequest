//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import os.log
import StringCaseConverter
import URLEncodedFormCodable

internal struct ResponseDecoding: Decoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var response: HTTPURLResponse
    var data: Data

    init(response: HTTPURLResponse, data: Data, codingPath: [CodingKey] = []) {
        self.response = response
        self.data = data
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = ResponseKeyedDecodingContainer(decoder: self, keyedBy: type, codingPath: codingPath)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ResponseSingleValueDecodingContainer(decoder: self, codingPath: codingPath)
    }

    func valueForHeaderCaseInsensitive<T>(_ header: String) -> T? {
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
                case is IntegerLiteralType.Type,
                     is IntegerLiteralType?.Type:
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

    func decodeBody<T: Decodable>(to type: T.Type) throws -> T {
        if type is PlainDecodable.Type {
            return try decodeString(type, from: data)
        }
        
        if type is JSONDecodable.Type {
            return try LoggingSnakeCaseJSONDecoder().decode(type, from: data)
        }

        if type is FormURLEncodedDecodable.Type {
            return try LoggingSnakeCaseURLEncodedFormDecoder().decode(type, from: data)
        }

        if type is CollectionProtocol.Type {
            guard let collectionType = type as? CollectionProtocol.Type else {
                preconditionFailure("this cast should not fail, contact the developers!")
            }

            let elementType = collectionType.getElementType()

            if elementType is PlainDecodable.Type {
                return try decodeString(type, from: data)
            }
            
            if elementType is JSONDecodable.Type {
                return try LoggingSnakeCaseJSONDecoder().decode(type, from: data)
            }

            if elementType is FormURLEncodedDecodable.Type {
                return try LoggingSnakeCaseURLEncodedFormDecoder().decode(type, from: data)
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

private class LoggingSnakeCaseJSONDecoder: LoggingJSONDecoder {
    override init() {
        super.init()
        self.keyDecodingStrategy = .convertFromSnakeCase
    }
}

private class LoggingSnakeCaseURLEncodedFormDecoder: URLEncodedFormDecoder {
    override init() {
        super.init()
        self.keyDecodingStrategy = .convertFromSnakeCase
    }

    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try super.decode(type, from: data)
        } catch {
            os_log("Failed to decode form-url-encoded data: %@\nReason: %@\nDetails: %@", type: .error, String(data: data, encoding: .utf8) ?? "nil", error.localizedDescription, String(describing: error))
            throw error
        }
    }
}
