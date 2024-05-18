//
//  Please refer to the LICENSE file for licensing information.
//

public struct DefaultErrorBodyStrategy: ResponseErrorBodyDecodingStrategy {
    public static func isError(statusCode: Int) -> Bool {
        statusCode >= HTTPStatusCode.badRequest.rawValue
    }
}
