//
//  Please refer to the LICENSE file for licensing information.
//

public protocol RequestHeaderValue {
    var serializedHeaderValue: String? { get }
}

extension String: RequestHeaderValue {
    public var serializedHeaderValue: String? { self }
}

extension Int: RequestHeaderValue {
    public var serializedHeaderValue: String? { description }
}

extension Bool: RequestHeaderValue {
    public var serializedHeaderValue: String? { serialized }
}

extension Optional: RequestHeaderValue where Wrapped: RequestHeaderValue {
    public var serializedHeaderValue: String? { self?.serializedHeaderValue }
}
