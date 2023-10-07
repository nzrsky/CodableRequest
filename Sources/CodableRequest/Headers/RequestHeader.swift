//
//  Please refer to the LICENSE file for licensing information.
//

internal protocol RequestHeaderProtocol {
    /// Custom name of the header item, can be nil
    var name: String? { get }

    /// Header value which should be serialized
    var untypedValue: RequestHeaderValue { get }
}

@propertyWrapper
public struct Header<T> where T: RequestHeaderValue {
    public var name: String?
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(name: String? = nil, defaultValue: T) {
        self.name = name
        wrappedValue = defaultValue
    }
}

public extension Header where T == String {
    init(name: String?) {
        self.name = name
        wrappedValue = ""
    }
}

public extension Header where T == String? {
    init(name: String?) {
        self.name = name
        wrappedValue = nil
    }
}

// MARK: - Encodable

extension Header: Encodable where T: Encodable {}

// MARK: - RequestHeaderProtocol

extension Header: RequestHeaderProtocol {
    var untypedValue: RequestHeaderValue {
        wrappedValue
    }
}
