//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct ResponseBodyWrapper<Body: Decodable, BodyStrategy: ResponseBodyDecodingStrategy> {
    public var wrappedValue: Body?

    public init() {
        wrappedValue = nil
    }

    public init(wrappedValue: Body?) {
        self.wrappedValue = wrappedValue
    }
}

extension ResponseBodyWrapper: Decodable {
    public init(from decoder: Decoder) throws {
        guard let responseDecoder = decoder as? ResponseDecoding else {
            wrappedValue = try Body(from: decoder)
            return
        }
        
        if !(HTTPStatusCode.ok ..< HTTPStatusCode.multipleChoices ~= responseDecoder.response.statusCode) {
            wrappedValue = nil
            return
        }

        if BodyStrategy.allowsEmptyContent(for: responseDecoder.response.statusCode), responseDecoder.data.isEmpty {
            wrappedValue = nil
            return
        }
                
        wrappedValue = try responseDecoder.decodeBody(to: Body.self)
    }
}
