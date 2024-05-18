//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct ErrorBodyWrapper<Body: Decodable, BodyStrategy: ResponseErrorBodyDecodingStrategy> {
    public var wrappedValue: Body?

    public init() {
        self.wrappedValue = nil
    }

    public init(wrappedValue: Body?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: Decodable

extension ErrorBodyWrapper: Decodable {
    public init(from decoder: Decoder) throws {
        guard let responseDecoder = decoder as? ResponseDecoding else {
            self.wrappedValue = try Body(from: decoder)
            return
        }
        guard BodyStrategy.isError(statusCode: responseDecoder.response.statusCode) else {
            self.wrappedValue = nil
            return
        }
        self.wrappedValue = try responseDecoder.decodeBody(to: Body.self)
    }
}
