//
//  Please refer to the LICENSE file for licensing information.
//

public struct ValidateStatus401ErrorBodyStrategy: ResponseErrorBodyDecodingStrategy {
    public static func isError(statusCode: Int) -> Bool {
        statusCode == HTTPStatusCode.unauthorized.rawValue
    }
}
