//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

@propertyWrapper
public struct ResponseCookies {

    public var wrappedValue: [HTTPCookie]

    public init(wrappedValue: [HTTPCookie] = []) {
        self.wrappedValue = wrappedValue
    }
}

extension ResponseCookies: Decodable {

    public init(from decoder: Decoder) throws {
        // Check if the decoder is response decoder, otherwise throw fatal error, because this property wrapper must use the correct decoder
        guard let responseDecoding = decoder as? AnyResponseDecoding else {
            preconditionFailure("\(Self.self) can only be used with \(AnyResponseDecoding.self)")
        }
        
        guard let url = responseDecoding.response.url,
            let allHeaderFields = responseDecoding.response.allHeaderFields as? [String: String] else {
            throw CodableRequestError.failedToDecodeHeaders
        }
        
        self.wrappedValue = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
    }
}
