//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct HTTPMethod: Encodable {

    public var wrappedValue: HTTPMethodValue

    public init(wrappedValue: HTTPMethodValue = .get) {
        self.wrappedValue = wrappedValue
    }
}
