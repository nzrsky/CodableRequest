//
//  Please refer to the LICENSE file for licensing information.
//

/// A type that has a default format of form-url-encoding
public protocol MultipartFormFormatProvider {
    /// Format of data, default extension is set to `.multipartForm`
    static var format: DataEncodingFormat { get }
}

extension MultipartFormFormatProvider {
    public static var format: DataEncodingFormat { .multipartForm }
}
