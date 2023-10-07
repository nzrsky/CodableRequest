//
//  Please refer to the LICENSE file for licensing information.
//

public enum URLEncodedElement {
    case text(String)
    case list([String])

    var string: String? {
        switch self {
        case .text(let value):
            return value
        default:
            return nil
        }
    }
}
