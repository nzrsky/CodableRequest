import Foundation

class RequestKeyedEncodingContainer<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    var codingPath: [CodingKey]
    let encoder: RequestEncoding

    init(for encoder: RequestEncoding, keyedBy type: Key.Type, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: Key) throws {
        encoder.addQueryItem(name: key.stringValue, value: nil)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        switch value {
        case let queryItem as QueryItem<String>:
            encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: queryItem.wrappedValue)
        case let queryItem as QueryItem<Int>:
            encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: queryItem.wrappedValue.description)
        case let queryItem as QueryItem<Bool>:
            encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: queryItem.wrappedValue ? "true" : "false")
        case let queryItem as QueryItem<[String]>:
            for value in queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value)
            }
        case let queryItem as QueryItem<[Int]>:
            for value in queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value.description)
            }
        case let queryItem as QueryItem<[Bool]>:
            for value in queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value  ? "true" : "false")
            }
        case let queryItem as QueryItem<String?>:
            if let value = queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value)
            }
        case let queryItem as QueryItem<Int?>:
            if let value = queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value.description)
            }
        case let queryItem as QueryItem<Bool?>:
            if let value = queryItem.wrappedValue {
                encoder.addQueryItem(name: queryItem.name ?? key.stringValue, value: value ? "true" : "false")
            }
        case let header as RequestHeader<String>:
            encoder.setHeader(name: header.name ?? key.stringValue, value: header.wrappedValue)
        case let header as RequestHeader<Int>:
            encoder.setHeader(name: header.name ?? key.stringValue, value: header.wrappedValue.description)
        case let header as RequestHeader<Bool>:
            encoder.setHeader(name: header.name ?? key.stringValue, value: header.wrappedValue ? "true" : "false")
        case let header as RequestHeader<String?>:
            if let value = header.wrappedValue {
                encoder.setHeader(name: header.name ?? key.stringValue, value: value)
            }
        case let header as RequestHeader<Int?>:
            if let value = header.wrappedValue {
                encoder.setHeader(name: header.name ?? key.stringValue, value: value.description)
            }
        case let header as RequestHeader<Bool?>:
            if let value = header.wrappedValue {
                encoder.setHeader(name: header.name ?? key.stringValue, value: value ? "true" : "false")
            }

        case let path as RequestPath:
            encoder.setPath(path.wrappedValue)
        case let method as RequestHTTPMethod:
            encoder.setHttpMethod(method.wrappedValue)
        default:
            // ignore any other values
            break
        }
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        RequestEncoding(parent: encoder, codingPath: [key]).container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        RequestEncoding(parent: encoder, codingPath: [key]).unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        encoder
    }

    func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        self == nil
    }
}