//
//  Please refer to the LICENSE file for licensing information.
//

public struct DefaultBodyStrategy: ResponseBodyDecodingStrategy {
    public static func allowsEmptyContent(for statusCode: Int) -> Bool { false }

    public static func validate(statusCode: Int) -> Bool {
        HTTPStatusCode.ok ..< HTTPStatusCode.multipleChoices ~= statusCode
    }
}
