//
//  Please refer to the LICENSE file for licensing information.
//

import Combine
import Foundation
import URLEncodedFormCodable

public class RequestEncoder {
    let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func encode<Request>(_ request: Request) throws -> URLRequest where Request: Encodable {
        try encodeToBaseURLRequest(request)
    }

    // MARK: - JSON

    public func encodeJson<Request>(request: Request) throws -> URLRequest where Request: JSONEncodable {
        var urlRequest = try encodeToBaseURLRequest(request)
        
        let encoder = JSONEncoder(keyEncodingStrategy: request.keyEncodingStrategy)
        urlRequest.httpBody = try encoder.encode(request.body)
        
        if urlRequest.value(for: .contentType) == nil {
            urlRequest.setValue(ContentTypeValue.json.rawValue, for: .contentType)
        }
        
        return urlRequest
    }

    // MARK: - Form URL Encoded

    public func encodeFormURLEncoded<Request>(request: Request) throws -> URLRequest where Request: FormURLEncodedEncodable {
        var urlRequest = try encodeToBaseURLRequest(request)
        let encoder = URLEncodedFormEncoder()
        urlRequest.httpBody = try encoder.encode(request.body)

        if urlRequest.value(for: .contentType) == nil {
            urlRequest.setValue(ContentTypeValue.formUrlEncoded.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }

    // MARK: - Plain

    public func encodePlain<Request>(request: Request) throws -> URLRequest where Request: PlainEncodable {
        var urlRequest = try encodeToBaseURLRequest(request)
        
        guard let body = request.body.data(using: request.encoding) else {
            throw CodableRequestError.failedToEncodePlainText(encoding: request.encoding)
        }
        urlRequest.httpBody = body

        if urlRequest.value(for: .contentType) == nil {
            urlRequest.setValue(ContentTypeValue.json.rawValue, for: .contentType)
        }
        
        return urlRequest
    }

    // MARK: - Shared

    private func encodeToBaseURLRequest<Request: Encodable>(_ request: Request) throws -> URLRequest {
        let encoder = RequestEncoding()
        try request.encode(to: encoder)

        var components: URLComponents
        
        // If a customURL got defined, use that one and append query items
        if let url = encoder.customURL {
            guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                throw RequestEncodingError.invalidCustomURL(url)
            }
            
            components = comps
        } else {
            var url = baseURL
            
            // If given, append custom path to base url
            var path = try encoder.resolvedPath()
            
            // If the defined path starts with a leading slash, trim it
            if encoder.path.starts(with: "/") {
                path = String(path.dropFirst())
            }
            
            if !path.isEmpty {
                url = url.appendingPathComponent(path)
            }
            
            guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                throw RequestEncodingError.invalidBaseURL
            }
            components = comps
        }

        if !encoder.queryItems.isEmpty {
            // Existing URL query items should not be overwritten, as they might
            // be set by the custom URL
            components.queryItems = components.queryItems.map { existingItems in
                let itemsSet = Set(existingItems.map(\.name))
                let newItems = encoder.queryItems.filter { !itemsSet.contains($0.name) }
                return existingItems + newItems
            } ?? encoder.queryItems
        }
        
        guard let url = components.url else {
            throw RequestEncodingError.failedToCreateURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = encoder.httpMethod.rawValue
        request.allHTTPHeaderFields = encoder.headers
        return request
    }
}

// MARK: - TopLevelEncoder

extension RequestEncoder: TopLevelEncoder {}

enum HTTPHeaderValue: String {
    case contentType = "Content-Type"
}

enum ContentTypeValue: String {
    case json = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}

extension URLRequest {
    mutating func setValue(_ value: String?, for field: HTTPHeaderValue) {
        setValue(value, forHTTPHeaderField: field.rawValue)
    }

    func value(for field: HTTPHeaderValue) -> String? {
        value(forHTTPHeaderField: field.rawValue)
    }
}

public enum CodableRequestError: LocalizedError {
    case failedToEncodePlainText(encoding: String.Encoding)

    public var errorDescription: String? {
        switch self {
        case .failedToEncodePlainText(let encoding):
            return "Failed to encode plain text body using encoding: \(encoding)"
        }
    }
}

extension JSONEncoder {
    convenience init(keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) {
        self.init()
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}
