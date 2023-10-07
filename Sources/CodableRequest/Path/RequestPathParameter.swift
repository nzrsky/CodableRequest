//
//  Please refer to the LICENSE file for licensing information.
//

/// Protocol used for untyped access to the embedded value
internal protocol RequestPathParameterProtocol {
    /// Custom name of the path parameter, can be nil
    var name: String? { get }

    /// Path parameter value which should be serialized and inserted into the path
    var untypedValue: RequestPathParameterValue { get }
}

@propertyWrapper
public struct PathParameter<T> where T: RequestPathParameterValue {
    public var name: String?
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public init(name: String?, defaultValue: T) {
        self.name = name
        self.wrappedValue = defaultValue
    }

    public static func getParameterType() -> Any.Type { T.self }
}

extension PathParameter: RequestPathParameterProtocol {
    internal var untypedValue: RequestPathParameterValue { wrappedValue }
}

extension PathParameter where T == String {
    public init(name: String?) {
        self.name = name
        self.wrappedValue = ""
    }
}

extension PathParameter where T == Int {
    public init(name: String?) {
        self.name = name
        self.wrappedValue = -1
    }
}

extension PathParameter where T == Int16 {
    public init(name: String?) {
        self.name = name
        self.wrappedValue = -1
    }
}

extension PathParameter where T == Int32 {
    public init(name: String?) {
        self.name = name
        self.wrappedValue = -1
    }
}

extension PathParameter where T == Int64 {
    public init(name: String?) {
        self.name = name
        self.wrappedValue = -1
    }
}

extension PathParameter: Encodable where T: Encodable {}

extension PathParameter: ExpressibleByNilLiteral where T: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.wrappedValue = nil
    }
}

extension PathParameter: ExpressibleByStringLiteral,
                                ExpressibleByExtendedGraphemeClusterLiteral,
                                ExpressibleByUnicodeScalarLiteral where T == String {
    public typealias ExtendedGraphemeClusterLiteralType = String.ExtendedGraphemeClusterLiteralType
    public typealias UnicodeScalarLiteralType = String.UnicodeScalarLiteralType
    public typealias StringLiteralType = String.StringLiteralType

    public init(stringLiteral value: String) {
        wrappedValue = value
    }
}

extension PathParameter: ExpressibleByIntegerLiteral where T == IntegerLiteralType {
    public init(integerLiteral value: IntegerLiteralType) {
        wrappedValue = value
    }
}
