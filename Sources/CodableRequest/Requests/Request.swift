//
//  Please refer to the LICENSE file for licensing information.
//

/// Protocol used to define a response type to a given request type
public protocol Request: Encodable {
    associatedtype Response: Decodable
}
