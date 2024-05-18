//
//  Please refer to the LICENSE file for licensing information.
//

import Foundation

/// Capable of converting `MultipartFormElement`.
protocol MultipartFormElementConvertible {
    /// Converts self to `MultipartFormElement`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data
}

extension Data: MultipartFormElementConvertible {
    
    // Magic headers
    func mimeType(for data: Data) -> String {
        var values = [UInt8](repeating: 0, count: 1)
        data.copyBytes(to: &values, count: 1)

        switch values.first {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "video/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        default:
            return "application/octet-stream"
        }
    }

    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        let mime = mimeType(for: self)
        let ext = mime.components(separatedBy: "/").last ?? ""

        var part = String()
        part.append("--\(boundary)\r\n")
        part.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).\(ext)\"\r\n")
        part.append("Content-Type: \(mime)\r\n\r\n")

        var data = Data()
        data.append(try part.data(using: encoding))
        data.append(self)
        data.append(try "\r\n".data(using: encoding))
        return data
    }
}

extension String: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        var part = String()
        part.append("--\(boundary)\r\n")
        part.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        part.append("\(self)\r\n")
        return try part.data(using: encoding)
    }
}

extension URL: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try absoluteString.encodePart(using: encoding, key: key, boundary: boundary)
    }
}

extension FixedWidthInteger {
    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try description.encodePart(using: encoding, key: key, boundary: boundary)
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
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try "\(self)".encodePart(using: encoding, key: key, boundary: boundary)
    }
}

extension Float: MultipartFormElementConvertible { }
extension Double: MultipartFormElementConvertible { }

extension Bool: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try description.encodePart(using: encoding, key: key, boundary: boundary)
    }
}

extension Decimal: MultipartFormElementConvertible {
    /// See `MultipartFormElementConvertible`.
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try description.encodePart(using: encoding, key: key, boundary: boundary)
    }
}

extension Array: MultipartFormElementConvertible where Element: MultipartFormElementConvertible {
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        var data = Data()
        for item in self {
            data.append(try item.encodePart(using: encoding, key: key, boundary: boundary))
        }
        return data
    }
}

extension Dictionary: MultipartFormElementConvertible where Value: MultipartFormElementConvertible, Key == String {
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        var data = Data()
        for (key, item) in self {
            data.append(try item.encodePart(using: encoding, key: key, boundary: boundary))
        }
        return data
    }
}

extension RawRepresentable where RawValue: MultipartFormElementConvertible {
    func encodePart(using encoding: String.Encoding, key: String, boundary: String) throws -> Data {
        try rawValue.encodePart(using: encoding, key: key, boundary: boundary)
    }
}

private extension String {
    func data(using encoding: String.Encoding) throws -> Data {
        guard let value = data(using: encoding) else {
            throw MultipartFormEncoder.EncodingError.elementIsNotMultipartEncodable
        }
        return value
    }
}
