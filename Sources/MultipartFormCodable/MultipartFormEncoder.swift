//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import Combine

public class MultipartFormEncoder: TopLevelEncoder {
    public enum EncodingError: LocalizedError {
        case elementIsNotMultipartEncodable
    }

    public let encoding: String.Encoding
    public let boundary: String = "Boundary-\(UUID().uuidString)"

    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let context = MultipartFormDataContext(encoding: encoding, boundary: boundary)
        let encoder = _MultipartFormEncoder(context: context)
        try value.encode(to: encoder)
        context.data.append("--\(boundary)--\r\n")
        return context.data
    }
}

class MultipartFormDataContext {
    let encoding: String.Encoding
    let boundary: String
    var data = Data()

    init(encoding: String.Encoding, boundary: String) {
        self.encoding = encoding
        self.boundary = boundary
    }
}

private final class _MultipartFormEncoder: Encoder {
    /// See `Encoder`
    var userInfo: [CodingUserInfoKey: Any] = [:]

    /// See `Encoder`
    var codingPath: [CodingKey] = []

    /// The data being decoded
    var context: MultipartFormDataContext

    /// Creates a new form url-encoded encoder
    init(context: MultipartFormDataContext, codingPath: [CodingKey] = []) {
        self.context = context
        self.codingPath = codingPath
    }

    /// See `Encoder`
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        .init(_MultipartFormKeyedEncoder<Key>(context: context, codingPath: codingPath))
    }

    /// See `Encoder`
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unkeyed encoding container not supported.")
    }

    /// See `Encoder`
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Single value encoding container not supported.")
    }
}

/// Private `KeyedEncodingContainerProtocol`.
private final class _MultipartFormKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    /// See `KeyedEncodingContainerProtocol`
    typealias Key = K

    /// See `KeyedEncodingContainerProtocol`
    var codingPath: [CodingKey]

    /// The data being encoded
    let context: MultipartFormDataContext

    /// Creates a new `_MultipartFormKeyedEncoder`.
    init(context: MultipartFormDataContext, codingPath: [CodingKey]) {
        self.context = context
        self.codingPath = codingPath
    }

    /// See `KeyedEncodingContainerProtocol`
    func encodeNil(forKey key: K) throws {
        // skip
    }

    /// See `KeyedEncodingContainerProtocol`
    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        let codingKey = (codingPath + [key]).map(\.stringValue).joined(separator: ".")
        if let convertible = value as? any MultipartFormElementConvertible {
            context.data.append(try convertible.encodePart(using: context.encoding, key: codingKey, boundary: context.boundary))
        } else if let rawRepresentable = value as? any RawRepresentable,
            let convertible = rawRepresentable.rawValue as? any MultipartFormElementConvertible {
            context.data.append(try convertible.encodePart(using: context.encoding, key: codingKey, boundary: context.boundary))
        }
    }

    /// See `KeyedEncodingContainerProtocol`
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        .init(_MultipartFormKeyedEncoder<NestedKey>(context: context, codingPath: codingPath + [key]))
    }

    /// See `KeyedEncodingContainerProtocol`
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("Unkeyed container is not supported")
    }

    /// See `KeyedEncodingContainerProtocol`
    func superEncoder() -> Encoder {
        _MultipartFormEncoder(context: context, codingPath: codingPath)
    }

    /// See `KeyedEncodingContainerProtocol`
    func superEncoder(forKey key: K) -> Encoder {
        _MultipartFormEncoder(context: context, codingPath: codingPath + [key])
    }
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
