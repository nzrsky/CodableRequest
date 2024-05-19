//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct ResponseBodyWrapper<Body: Decodable, BodyStrategy: ResponseBodyDecodingStrategy> {
    public var wrappedValue: Body?

    public init() {
        self.wrappedValue = nil
    }

    public init(wrappedValue: Body?) {
        self.wrappedValue = wrappedValue
    }
}

extension ResponseBodyWrapper: Decodable {
    public init(from decoder: Decoder) throws {
        guard let responseDecoder = decoder as? AnyResponseDecoding else {
            self.wrappedValue = try Body(from: decoder)
            return
        }

        guard BodyStrategy.validate(statusCode: responseDecoder.response.statusCode) else {
            self.wrappedValue = nil
            return
        }

        if responseDecoder.data.isEmpty &&
            BodyStrategy.allowsEmptyContent(for: responseDecoder.response.statusCode), responseDecoder.data.isEmpty {
            wrappedValue = nil
            return
        }
                
        wrappedValue = try responseDecoder.decodeBody(to: Body.self)
    }
}
