//
//  Please refer to the LICENSE file for licensing information.
//

public typealias ResponseBody<Body: Decodable> = ResponseBodyWrapper<Body, DefaultBodyStrategy>
