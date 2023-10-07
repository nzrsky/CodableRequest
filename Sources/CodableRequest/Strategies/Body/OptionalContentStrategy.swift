//
//  Please refer to the LICENSE file for licensing information.
//

public class OptionalContentStrategy: ResponseBodyDecodingStrategy {
    public static func allowsEmptyContent(for statusCode: Int?) -> Bool { statusCode == Int(HTTPStatusCode.noContent.rawValue) }
}
