public struct DefaultBodyStrategy: ResponseBodyDecodingStrategy {
    public static func allowsEmptyContent(for statusCode: Int? = nil) -> Bool { false }
}
