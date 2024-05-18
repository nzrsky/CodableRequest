//
//  Please refer to the LICENSE file for licensing information.
//

public typealias ErrorBody<Body: Decodable> = ErrorBodyWrapper<Body, DefaultErrorBodyStrategy>
