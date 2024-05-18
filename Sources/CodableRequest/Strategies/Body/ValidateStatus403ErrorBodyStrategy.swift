//
//  Please refer to the LICENSE file for licensing information.
//

public struct ValidateStatus403ErrorBodyStrategy: ResponseErrorBodyDecodingStrategy {
    public static func isError(statusCode: Int) -> Bool {
        statusCode == HTTPStatusCode.forbidden.rawValue
    }
}
