//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation
import Combine

public class MultipartFormEncoder: TopLevelEncoder {
    public enum EncodingError: LocalizedError {
        case failedToConvertUsingEncoding
    }

    public let encoding: String.Encoding
    public let boundary: String = "Boundary-\(UUID().uuidString)"

    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let context = MultipartFormDataContext()
        let encoder = _MultipartFormEncoder(context: context)
        try value.encode(to: encoder)

        var body = Data()

        let partHeader = "--\(boundary)\r\nContent-Disposition: form-data"
        for (key, value) in context.fields.sorted(by: { lhs, rhs in lhs.key < rhs.key }) {
            switch value {
            case let .text(string):
                body.append(try "\(partHeader); name=\"\(key)\"\r\n\r\n\(string)\r\n".dataOrThrow(using: encoding))
            case let .file(file):
                let part = "\(partHeader); name=\"\(key)\"; filename=\"\(file.filename)\"\r\nContent-Type: \(file.contentType)\r\n\r\n"
                body.append(try part.dataOrThrow(using: encoding))
                body.append(file.content)
                body.append(try "\r\n".dataOrThrow(using: encoding))
            }
        }
        body.append(try "--\(boundary)--\r\n".dataOrThrow(using: encoding))
        return body
    }
}

private extension String {
    func dataOrThrow(using encoding: String.Encoding) throws -> Data {
        guard let value = data(using: encoding) else {
            throw MultipartFormEncoder.EncodingError.failedToConvertUsingEncoding
        }
        return value
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
        if let convertible = value as? MultipartFormElementConvertible {
            try context.set(convertible.convertToMultipartFormElement(), at: codingPath + [key])
        } else {
            throw MultipartFormEncoder.EncodingError.failedToConvertUsingEncoding
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

class MultipartFormDataContext {

    var fields: [String: MultipartFormElement] = [:]

    func set(_ element: MultipartFormElement, at path: [CodingKey]) {
        let key = path.map(\.stringValue).joined(separator: ".")
        fields[key] = element
    }
}
