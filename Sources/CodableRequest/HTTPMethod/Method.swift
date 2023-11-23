//
//  Please refer to the LICENSE file for licensing information.
//

@propertyWrapper
public struct Method: Encodable {

    public var wrappedValue: MethodValue

    public init(wrappedValue: MethodValue = .get) {
        self.wrappedValue = wrappedValue
    }
}
