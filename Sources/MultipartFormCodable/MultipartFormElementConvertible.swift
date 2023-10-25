//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// Capable of converting to / from `MultipartFormElement`.
protocol MultipartFormElementConvertible {
    /// Converts self to `MultipartFormElement`.
    func convertToMultipartFormElement() throws -> MultipartFormElement
}

extension String: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text(self)
    }
}

extension URL: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text(absoluteString)
    }
}

extension FixedWidthInteger {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text(description)
    }
}

extension Int: MultipartFormElementConvertible { }
extension Int8: MultipartFormElementConvertible { }
extension Int16: MultipartFormElementConvertible { }
extension Int32: MultipartFormElementConvertible { }
extension Int64: MultipartFormElementConvertible { }
extension UInt: MultipartFormElementConvertible { }
extension UInt8: MultipartFormElementConvertible { }
extension UInt16: MultipartFormElementConvertible { }
extension UInt32: MultipartFormElementConvertible { }
extension UInt64: MultipartFormElementConvertible { }

extension BinaryFloatingPoint {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text("\(self)")
    }
}

extension Float: MultipartFormElementConvertible { }
extension Double: MultipartFormElementConvertible { }

extension Bool: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text(description)
    }
}

extension Decimal: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .text(description)
    }
}

extension MultipartFormElement.File: MultipartFormElementConvertible {
    func convertToMultipartFormElement() throws -> MultipartFormElement {
        .file(self)
    }
}
