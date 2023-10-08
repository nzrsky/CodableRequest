//
//  Please refer to the LICENSE file for licensing information.
//

public protocol RequestPathParameterValue {
    var serialized: String { get }
}

extension Bool: RequestPathParameterValue {
    public var serialized: String { self ? "true" : "false" }
}

extension String: RequestPathParameterValue {
    public var serialized: String { self }
}

extension Int: RequestPathParameterValue {
    public var serialized: String { description }
}

extension Int16: RequestPathParameterValue {
    public var serialized: String { description }
}

extension Int32: RequestPathParameterValue {
    public var serialized: String { description }
}

extension Int64: RequestPathParameterValue {
    public var serialized: String { description }
}

extension Optional: RequestPathParameterValue where Wrapped: RequestPathParameterValue {
    public var serialized: String {
        switch self {
        case let .some(value):
            return value.serialized
        case .none:
            return "nil"
        }
    }
}
