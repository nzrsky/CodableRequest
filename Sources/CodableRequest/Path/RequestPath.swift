//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct Path: Encodable {

    public var wrappedValue: String

    public init(wrappedValue: String = "") {
        self.wrappedValue = wrappedValue
    }
}

extension Path: ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = String.ExtendedGraphemeClusterLiteralType
    public typealias UnicodeScalarLiteralType = String.UnicodeScalarLiteralType
    public typealias StringLiteralType = String.StringLiteralType

    public init(stringLiteral value: String) {
        wrappedValue = value
    }
}
