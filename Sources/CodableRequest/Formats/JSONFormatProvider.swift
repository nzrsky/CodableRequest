//
//  Please refer to the LICENSE file for licensing information.
//

/// A type that has a default format of form-url-encoding
public protocol JSONFormatProvider {
    /// Format of data, default extension is set to `.json`
    static var format: DataEncodingFormat { get }
}

extension JSONFormatProvider {
    public static var format: DataEncodingFormat { .json }
}
