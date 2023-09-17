import Combine
import Foundation

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
        urlRequest.httpBody = try encodeJsonBody(request.body, keyEncodingStrategy: request.keyEncodingStrategy)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }

    private func encodeJsonBody<Body: Encodable>(_ body: Body, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        return try encoder.encode(body)
    }

    // MARK: - Plain

    public func encodePlain<Request>(request: Request) throws -> URLRequest where Request: PlainEncodable {
        var urlRequest = try encodeToBaseURLRequest(request)
        urlRequest.httpBody = try encodePlainBody(request.body, encoding: request.encoding)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }

    private func encodePlainBody(_ body: String, encoding: String.Encoding) throws -> Data {
        guard let data = body.data(using: encoding) else {
            throw APIError.failedToEncodePlainText(encoding: encoding)
        }
        return data
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
            components.queryItems = encoder.queryItems
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
