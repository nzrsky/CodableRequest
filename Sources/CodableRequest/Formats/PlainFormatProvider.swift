//
//  Please refer to the LICENSE file for licensing information.
//

/// A type that has a default format of form-url-encoding
public protocol PlainFormatProvider {
    /// Format of data, default extension is set to `.json`
    static var format: DataEncodingFormat { get }
}

extension PlainFormatProvider {
    public static var format: DataEncodingFormat { .plain }
}
